--[ Colossus ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.nstg)
	e1:SetOperation(s.nsop)
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
	
	local e3=MakeEff(c,"Qo","G")
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCost(aux.bfgcost)
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
	
end

function s.nsfilter(c,e,tp)
	if not c:IsSetCard(0x3d6f) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_RELEASE_SUM)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
	local res=c:IsSummonable(true,nil)
	e1:Reset()
	return res
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
	local pos=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsStatus(STATUS_ACT_FROM_HAND) and c:IsPreviousPosition(POS_FACEDOWN) and POS_FACEDOWN or 0
	Duel.SetTargetParam(pos)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	local pos=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tc then
		if pos&POS_FACEDOWN>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_EXTRA_RELEASE_SUM)
			e1:SetTargetRange(0,LOCATION_MZONE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCountLimit(1)
			e1:SetReset(RESETS_STANDARD)
			Duel.RegisterEffect(e1,tp)
		end
		if tc:IsSummonable(true,nil) then
			Duel.Summon(tp,tc,true,nil)
		end
	end
end

function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,LOCATION_ONFIELD,0,1,nil)
end

function s.tar3fil(c)
	return c:IsAbleToDeck() and c:IsSetCard(0x3d6f) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar3fil,tp,LOCATION_GRAVE|LOCATION_MZONE,0,4,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(s.tar3fil,tp,LOCATION_GRAVE|LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,4,tp,LOCATION_GRAVE|LOCATION_MZONE)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tar3fil,tp,LOCATION_GRAVE|LOCATION_MZONE,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=g:Select(tp,4,4,nil)
		Duel.HintSelection(sg)
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	local og=Duel.GetOperatedGroup()
	if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
	if ct>0 and Duel.IsPlayerCanDraw(tp) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

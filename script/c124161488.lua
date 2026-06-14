--엔비램블 딜루젼
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	return g>0
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,124161476,0xf3f,TYPES_TOKEN,300,0,1,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2
		or not Duel.IsPlayerCanSpecialSummonCount(tp,2)
		or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,124161476,0xf3f,TYPES_TOKEN,300,0,1,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP,tp) then return end
	local token_g=Group.CreateGroup()
	for i=1,2 do
		local token=Duel.CreateToken(tp,124161476)
		token_g:AddCard(token)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
	Duel.BreakEffect()
	local tc=token_g:GetFirst()
	if not tc or not tc:IsLocation(LOCATION_MZONE) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_EXTRA_MATERIAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetOperation(s.extracon)
	e1:SetValue(s.extraval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local g=Duel.GetMatchingGroup(Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,1,1,nil)
		local sc=sg:GetFirst()
		if sc then
			Duel.LinkSummon(tp,sc)
			local eff_code=Duel.GetCurrentChain()==1 and EVENT_SPSUMMON or EVENT_SPSUMMON_SUCCESS
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(eff_code)
			e2:SetOperation(function(e) e1:Reset() e:Reset() end)
			Duel.RegisterEffect(e2,tp)
		else
			e1:Reset()
		end
	else
		e1:Reset()
	end
end

function s.extrafilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf3f) and c:IsMonster()
end

function s.extracon(c,e,tp,sg,mg,lc,og,chk)
	local g=Duel.GetMatchingGroup(s.extrafilter,tp,0,LOCATION_MZONE,nil)
	return #(sg&g)<=1
end

function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK then
			return Group.CreateGroup()
		else
			return Duel.GetMatchingGroup(s.extrafilter,tp,0,LOCATION_MZONE,nil)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK and #sg>0 then
			Duel.Hint(HINT_CARD,tp,id)
		end
	end
end

--effect 2
function s.cst2filter(c)
	return c:IsSetCard(0xf3f) and c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
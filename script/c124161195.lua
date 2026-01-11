--페더록스 어센션
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

function s.tg1ffilter(c)
	return c:IsSetCard(0xf2c) and c:IsAbleToRemove()
end

function s.tg1filter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and c:IsRankAbove(2) and Duel.GetMatchingGroupCount(s.tg1ffilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,e:GetHandler())>=c:GetRank()//2 and Duel.GetLocationCountFromEx(tp,tp,nil,c)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON):GetFirst()
	Duel.ConfirmCards(1-tp,sg)
	e:SetLabelObject(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local x=e:GetLabelObject()
	local rk=x:GetRank()
	local g=Duel.GetMatchingGroup(s.tg1ffilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,e:GetHandler())
	if #g>=rk//2 then
		local sg=aux.SelectUnselectGroup(g,e,tp,rk//2,rk//2,aux.TRUE,1,tp,HINTMSG_REMOVE)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		if Duel.GetLocationCountFromEx(tp,tp,nil,x) then
			Duel.BreakEffect()
			Duel.SpecialSummon(x,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			x:CompleteProcedure()
		end
	end
end

--effect 2
function s.tg2filter(c,e)
	return c:IsSetCard(0xf2c) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and c:IsFaceup()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_REMOVED,0,e:GetHandler(),e)
	if chk==0 then return #g>3 and Duel.IsPlayerCanDraw(tp,1) end
	local sg=aux.SelectUnselectGroup(g,e,tp,4,4,aux.TRUE,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
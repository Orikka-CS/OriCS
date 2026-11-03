--비블리오션 인덱스
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c)
	return c:IsSetCard(0x6f20) and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.op1filter(c)
	return c:IsContinuousSpell() and c:IsAbleToDeck()
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
	if Duel.SendtoGrave(sg,REASON_EFFECT)==0 then return end
	Duel.ShuffleDeck(tp)
	local dg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.op1filter),tp,LOCATION_GRAVE,0,nil)
	if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		local dsg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
		Duel.DisableShuffleCheck()
		Duel.SendtoDeck(dsg,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end

--effect 2
function s.tg2filter(c,b)
	return (c:IsSetCard(0x6f20) and not c:IsCode(id)) or (b and c:IsContinuousSpell())
end
function s.tg2ffilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local b=Duel.GetMatchingGroupCount(s.tg2ffilter,tp,LOCATION_MZONE,0,nil)>0
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil,b)
	if chk==0 then return #g>0 end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local b=Duel.GetMatchingGroupCount(s.tg2ffilter,tp,LOCATION_MZONE,0,nil)>0
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil,b)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SELECT):GetFirst()
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(sg,SEQ_DECKTOP)
		Duel.ConfirmDecktop(tp,1)
		Duel.DisableShuffleCheck()
	end
end

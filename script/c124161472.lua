--브릿지버스터 레조넌스
local s,id=GetID()
function s.initial_effect(c)
	--activate from hand
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(function(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)>1 end)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
end

--effect 1
function s.tg1filter(c)
	return c:IsSetCard(0xf3e) and c:IsFaceup()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>1 end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.op1atkval(c)
	return c:IsSetCard(0xf3e) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end

function s.op1atkval(c)
	return math.max(c:GetAttack(),0)
end

function s.op1tdfilter(c)
	return c:IsAbleToDeck()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local atk=g:GetSum(s.op1atkval)
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	local ct=Duel.GetMatchingGroupCount(s.op1filter,tp,LOCATION_MZONE,0,nil)
	local dg=Duel.GetMatchingGroup(s.op1tdfilter,tp,0,LOCATION_ONFIELD,nil)
	if ct>0 and #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		local sg=aux.SelectUnselectGroup(dg,e,tp,1,ct,aux.TRUE,1,tp,HINTMSG_TODECK)
		Duel.DisableShuffleCheck()
		Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		local og=Duel.GetOperatedGroup()
		local tc1=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		if tc1>1 then
			Duel.SortDecktop(tp,1-tp,tc1)
		end
	end
end
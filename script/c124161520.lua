--페를라렌트 그럿지
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c,e)
	return c:IsSetCard(0xf41) and c:IsMonster() and c:IsFaceup() and c:IsCanBeEffectTarget(e)
end

function s.tg1ofilter(c)
	return c:IsFaceup() and c:GetEquipCount()>0
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg1filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return #g>0 and Duel.GetMatchingGroupCount(s.tg1ofilter,tp,0,LOCATION_MZONE,nil)>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,sg,1,tp,0)
end

function s.op1atkval(c)
	return math.max(c:GetAttack(),0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if not (tg and tg:IsRelateToEffect(e) and tg:IsFaceup()) then return end
	local c=e:GetHandler()
	if tg:IsImmuneToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.tg1ofilter,tp,0,LOCATION_MZONE,nil)
	local atk=g:GetSum(s.op1atkval)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tg:RegisterEffect(e1)
	local og=Duel.GetMatchingGroup(s.tg1ofilter,tp,0,LOCATION_MZONE,nil)
	if #og>0 then
		Duel.BreakEffect()
		for oc in og:Iter() do
			if not oc:IsImmuneToEffect(e) then
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_SET_ATTACK_FINAL)
				e2:SetValue(0)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				oc:RegisterEffect(e2)
			end
		end
	end
end

--effect 2
function s.con2eqfilter(c,tp,tc)
	return c:IsControler(tp) and c:GetEquipTarget()==tc
end

function s.con2filter(c,tp)
	return c:IsFaceup() and Duel.GetMatchingGroupCount(s.con2eqfilter,tp,LOCATION_SZONE,0,nil,tp,c)>0
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con2filter,tp,0,LOCATION_MZONE,nil,tp)
	return g>0
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.SSet(tp,c)
	end
end
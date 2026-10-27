--언엔달 에시멀
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.con2)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1filter(c)
	return c:IsCode(124162013) and c:IsFaceup()
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_ONFIELD,0,nil)>0
end
function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler())
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(sg,REASON_COST)
end
function s.tg1filter(c)
	return c:IsFaceup() and (c:GetAttack()~=0 or (c:HasDefense() and c:GetDefense()~=0))
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2)
	end
end

--effect 2
function s.con2filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3f20) and c:IsType(TYPE_XYZ)
end
function s.con2(e)
	return Duel.GetMatchingGroupCount(s.con2filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)>0
end
function s.val2(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsAttackBelow(Duel.GetFlagEffect(e:GetHandlerPlayer(),124162013)*500)
end

--휴프알로 룩 라마트쉬
local s,id=GetID()
function s.initial_effect(c)
	--xyz
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,6,2,s.ovfilter,aux.Stringid(id,0),2,s.ovop)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--xyz
function s.ovfilter(c,tp,lc)
	return c:IsFacedown() and c:IsCanBeXyzMaterial() and c:IsControler(tp) and c:IsLevel(6) and c:IsSetCard(0xf2a)
end

function s.ovop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end

--effect 1
function s.tg1filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e) and c:IsAttackAbove(1) and c:IsCanTurnSet()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg2filter(chkc,e,tp) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,0,e:GetHandler(),e,tp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_POSCHANGE)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,#sg,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg and tg:IsFaceup() and tg:IsAttackAbove(1) then
		c:UpdateAttack(tg:GetAttack(),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		Duel.ChangePosition(tg,POS_FACEDOWN_DEFENSE)
	end
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsSetCard(0xf2a) and rp==tp
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFacedown() and c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.op2filter(e,c)
	return (c:IsSetCard(0xf2a) and c:IsFaceup()) or c:IsFacedown()
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(s.op2filter)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
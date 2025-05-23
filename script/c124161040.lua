--시엄브라레 아페피스
local s,id=GetID()
function s.initial_effect(c)
	--link
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf22),2)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SSET)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local b1=Duel.IsChainNegatable(ev)
	local b2=false
	if rc:GetOwner()==tp and rc:IsSetCard(0xf22) and rc:IsSpellTrap() and not rc:IsType(TYPE_FIELD) then
		local eff=rc:GetActivateEffect()
		local ta=eff:GetTarget()
		if rc:GetControler()==tp and ta(e,1-tp,eg,ep,ev,re,r,rp,0) then
			b2=true
		elseif rc:GetControler()==1-tp and ta(e,tp,eg,ep,ev,re,r,rp,0) then
			b2=true
		else
			b2=false
		end
	end
	if chk==0 then return (b1 or b2) end
	local b=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	e:SetLabel(b)
	if b==1 then
		e:SetCategory(CATEGORY_NEGATE)
		Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	else
		e:SetCategory(0)
		Duel.ClearOperationInfo(0)
	end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local b=e:GetLabel()
	if b==1 then
		Duel.NegateActivation(ev)
	elseif b==2 then
		local rc=re:GetHandler()
		local eff=rc:GetActivateEffect()
		if rc:GetControler()==tp then
			local op=eff:GetOperation()
			if op then op(e,1-tp,eg,ep,ev,re,r,rp,2) end
		else
			local op=eff:GetOperation()
			if op then op(e,tp,eg,ep,ev,re,r,rp,1) end
		end
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_STZONE)
end

function s.con2(e,tp,eg)
	return eg:IsExists(s.con2filter,1,nil,tp)
end

function s.tg2filter(c,e)
	return c:IsFaceup() and c:IsAbleToChangeControler() and c:IsCanBeEffectTarget(e)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,0,LOCATION_MZONE,nil,e)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tg2filter(chkc,e) end
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONTROL)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,sg,1,tp,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg then
		Duel.GetControl(tg,tp)
	end
end
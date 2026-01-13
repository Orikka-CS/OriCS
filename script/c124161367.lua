--볼틱갭츠 패럴라이존
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DISABLE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.tg2)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end

--effect 1
function s.con1filter(c)
	return c:IsSetCard(0xf37) and c:IsType(TYPE_LINK) and c:IsLinked() and c:IsFaceup()
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_MZONE,0,nil)
	return rp==1-tp and Duel.IsChainDisablable(ev) and g>0
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

function s.op1lfilter(c)
	return c:IsFaceup() and c:IsLinked()
end

function s.op1filter(c,diff)
	return c:IsFaceup() and c:GetAttack()<=diff and c:IsNegatable()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateEffect(ev) then
		local g=Duel.GetMatchingGroup(s.op1lfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if #g>0 then
			local _,max=g:GetMaxGroup(Card.GetAttack)
			local _,min=g:GetMinGroup(Card.GetAttack)
			local diff=max-min
			local dg=Duel.GetMatchingGroup(s.op1filter,tp,0,LOCATION_MZONE,nil,diff)
			if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.BreakEffect()
				local sg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_NEGATE):GetFirst()
				sg:NegateEffects(c,RESET_PHASE+PHASE_END,false)
				Duel.Recover(tp,sg:GetAttack(),REASON_EFFECT)
			end
		end
	end
end

--effect 2
function s.tg2(e,c)
	return c:IsSetCard(0xf37) and c:IsLinked()
end
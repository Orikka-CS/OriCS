--체레넬라제 해필리에버애프터
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.con0)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--activate
function s.con0filter(c)
	return c:IsFaceup() and c:IsCode(124161426)
end

function s.con0(e)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroupCount(s.con0filter,tp,LOCATION_ONFIELD,0,nil)
	return g>0
end

--effect 1
function s.con1filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf3b) and c:IsType(TYPE_LINK)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_MZONE,0,nil)
	local b1=re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
	local b2=(rp==1-tp) and re:IsActiveType(TYPE_MONSTER)
	return g>0 and (b1 or b2) and Duel.IsChainNegatable(ev)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local dg=Group.CreateGroup()
	for i=1,ev do
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		local b1=te:IsActiveType(TYPE_SPELL) and te:IsHasType(EFFECT_TYPE_ACTIVATE)
		local b2=(tgp==1-tp) and te:IsActiveType(TYPE_MONSTER)
		if b1 or b2 then
			Duel.NegateActivation(i) 
			local tc=te:GetHandler()
			if tc:IsRelateToEffect(te) then
				dg:AddCard(tc)
			end
		end
	end
	if #dg>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end

--effect 2
function s.tg2ctfilter(c)
	return c:IsCode(124161426) and c:IsFaceup()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(s.tg2ctfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)>0 end
	local ct=Duel.GetMatchingGroupCount(s.tg2ctfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*1500)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.tg2ctfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	if ct>0 then
		Duel.Recover(tp,ct*1500,REASON_EFFECT)
	end
end
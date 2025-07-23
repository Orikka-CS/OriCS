--백연초가 인도하는 끝으로
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(aux.exccon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf2b) and c:IsType(TYPE_FUSION)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_MZONE,0,nil)>0 and Duel.IsChainNegatable(ev) and rp==1-tp
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local cl=Duel.GetCurrentChain()
	if chk==0 then return Duel.CheckLPCost(tp,cl*500) end
	Duel.PayLPCost(tp,cl*500)
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
		if tgp~=tp then
			Duel.NegateActivation(i) 
			if te:GetHandler():IsRelateToEffect(te) then
				dg:AddCard(te:GetHandler())
			end
		end
	end
	if #dg>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end

--effect 2
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,124161179)>0 end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,500)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFlagEffect(tp,124161179)
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
end
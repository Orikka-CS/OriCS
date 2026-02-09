--뮬베이릿 알티마
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:GetHandler():IsSetCard(0xf3a)
end

function s.tg1filter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsCanBeEffectTarget(e)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tg1filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_MZONE,nil,e)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e):GetFirst()
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 and tg and tg:IsFaceup() then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(s.op1con)
		e1:SetTarget(s.op1tg)
		e1:SetOperation(s.op1op)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tg:RegisterEffect(e1,true)
	end
end

function s.op1con(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:FilterCount(Card.IsControler,nil,tp)
end

function s.op1tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end

function s.op1op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

--effect 2
function s.con2filter(c)
	return c:IsSetCard(0xf3a) and c:IsFaceup()
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con2filter,tp,LOCATION_MZONE,0,nil)
	return rp==1-tp and g>0 and Duel.IsChainDisablable(ev) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
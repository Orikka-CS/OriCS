--Calapis Meltdown
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf27)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_MZONE,0,nil)>0 and Duel.IsChainNegatable(ev) and rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if e:GetHandler():IsPreviousLocation(LOCATION_REMOVED) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		e:SetLabel(1)
		e:SetCategory(CATEGORY_NEGATE+CATEGORY_TOGRAVE)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,rp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD)
	else
		e:SetCategory(CATEGORY_NEGATE)
		e:SetLabel(0)
	end 
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		if e:GetLabel()==0 then return end
		local cd=re:GetHandler():GetCode()
		local g=Duel.GetMatchingGroup(Card.IsCode,rp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,nil,cd)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end

--effect 2
function s.cst2filter(c)
	return c:IsSetCard(0xf27) and c:IsAbleToRemoveAsCost()
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_GRAVE,0,c)
	if chk==0 then return c:IsAbleToRemoveAsCost() and #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE)
	Duel.Remove(c+sg,POS_FACEUP,REASON_COST)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,nil,1,tp,HINTMSG_REMOVE)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
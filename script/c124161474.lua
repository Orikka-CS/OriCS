--브릿지버스터 사보타주
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
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
	return c:IsFaceup() and c:IsSetCard(0xf3e) and c:IsType(TYPE_XYZ)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_MZONE,0,nil)
	return g>0 and rp==1-tp and Duel.IsChainNegatable(ev)
end

function s.tg1filter(c,code)
	return c:IsCode(code) and c:IsAbleToGrave()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local code=rc:GetCode()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_ONFIELD,nil,code)
	if chk==0 then return true end
	e:SetLabel(code)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	if Duel.NegateActivation(ev) then
		local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_ONFIELD,nil,code)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end

--effect 2
function s.cst2filter(c)
	return c:IsSetCard(0xf3e) and c:IsAbleToGraveAsCost()
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Group.CreateGroup()
	local mg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_XYZ)
	for tc in mg:Iter() do
		g:Merge(tc:GetOverlayGroup():Filter(s.cst2filter,nil))
	end
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(sg,REASON_COST)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
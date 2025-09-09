--테일모어 글루토네
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK+CATEGORY_TOGRAVE)
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
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_DECK)
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
	return rp==1-tp and Duel.IsChainNegatable(ev) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end

function s.cst1filter(c)
	return c:IsSetCard(0xf2f) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsAbleToDeckAsCost()
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,e:GetHandler())
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0) 
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local ac=3
	local g=Duel.GetDecktopGroup(tp,ac)
	Duel.SendtoGrave(g,REASON_EFFECT)
	g=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #g>0 then
		Duel.BreakEffect()
		if not Duel.NegateActivation(ev) or not rc:IsRelateToEffect(re) then return end
		rc:CancelToGrave()
		Duel.SendtoDeck(rc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsPreviousControler(tp) and c:IsContinuousSpell() and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_SZONE+LOCATION_GRAVE)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.con2filter,1,nil,tp)
end

function s.tg2filter(c)
	return c:IsContinuousSpell() and c:IsAbleToGrave() 
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,tp,LOCATION_DECK)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
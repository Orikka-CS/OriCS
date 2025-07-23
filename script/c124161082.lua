--아스타테리아 칼리
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2i)
	e2:SetCost(Cost.SelfToDeck)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(s.con2q)
	c:RegisterEffect(e3)
end

--effect 1
function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) and 
	Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	Duel.DiscardDeck(tp,1,REASON_COST)
end

function s.tg1filter(c)
	return c:IsSetCard(0xf25) and c:IsSpellTrap() and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil,e,tp)
	if chk==0 then return #g>0 end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil,e,tp)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

--effect 2
function s.con2filter(c)
	return c:IsSetCard(0xf25)
end

function s.con2i(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ug=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	local dg=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	local g=Duel.GetMatchingGroupCount(s.con2filter,tp,LOCATION_GRAVE,0,c)
	return g>0 and ug==dg
end

function s.con2q(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ug=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	local dg=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	local g=Duel.GetMatchingGroupCount(s.con2filter,tp,LOCATION_GRAVE,0,c)
	return g>0 and ug~=dg
end

function s.tg2filter(c,e)
	return c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.tg2filter(chkc,e) end
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,0,LOCATION_GRAVE,nil,e)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg then
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
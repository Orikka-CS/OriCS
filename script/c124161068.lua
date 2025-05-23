--사이클래시 페이
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.cst1filter(c)
	return c:IsSetCard(0xf24) and not c:IsPublic()
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_HAND,0,c)
	if chk==0 then return c:IsDiscardable() and #g>0 end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONFIRM)
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(tp)
end

function s.tg1sfilter(c)
	local te=c:GetActivateEffect()
	return c:IsSpell() and te:IsHasCategory(CATEGORY_DESTROY) and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1sfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1sfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end 
end

--effect 2
function s.tg2filter(c)
	return c:IsSetCard(0xf24) and c:IsAbleToDeck()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)  
	local c=e:GetHandler()
	local dg=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_GRAVE,0,c)
	if chk==0 then return #dg>1 and c:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,dg+c,3,0,LOCATION_GRAVE)
end

function s.op2filter(c)
	return c:IsSetCard(0xf24) and c:IsTrap() and c:IsSSetable()
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dg=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_GRAVE,0,c)
	if #dg>1 and c:IsRelateToEffect(e) then
		local dsg=aux.SelectUnselectGroup(dg,e,tp,2,2,aux.TRUE,1,tp,HINTMSG_TODECK)  
		Duel.SendtoDeck(dsg+c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) 
		local g=Duel.GetMatchingGroup(s.op2filter,tp,LOCATION_DECK,0,nil)
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SET)
			Duel.SSet(tp,sg)
		end
	end
end
--StarLightshape's Charity
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CONFIRM)
	e2:SetRange(LOCATION_HAND)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end

function s.op1filter(c)
	return c:IsSetCard(0xf20) and not c:IsPublic()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.Draw(tp,2,REASON_EFFECT) then return end
	local g=Duel.GetMatchingGroup(s.op1filter,tp,LOCATION_HAND,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONFIRM)
		Duel.BreakEffect()
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleHand(tp)
	else
		local sg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		Duel.BreakEffect()
		Duel.ConfirmCards(1-tp,sg)
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

--effect 2
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
end

function s.op2filter(c)
	return c:IsPublic() and c:IsAbleToDeck()
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPublic() or not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	c:RegisterEffect(e1)
	local g=Duel.GetMatchingGroup(s.op2filter,tp,LOCATION_HAND,0,nil)
	g=g+c
	if #g>0 and Duel.IsPlayerCanDraw(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		local sg=aux.SelectUnselectGroup(g,e,tp,1,#g,nil,1,tp,HINTMSG_TODECK)
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
		Duel.Draw(tp,#sg,REASON_EFFECT)
	end
end

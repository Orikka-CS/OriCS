--메가히트 디조넌스
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():IsReason(REASON_EFFECT) end)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--count
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DRAW)
		ge1:SetOperation(s.cnt)
		Duel.RegisterEffect(ge1,0)
	end)
end

--count
function s.cnt(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFlagEffect(ep,id)
	if Duel.GetTurnCount()==0 then return end
	if ev>ct then
		for i=1,ev-ct do
			Duel.RegisterFlagEffect(ep,id,0,0,1)
		end
	end
end

--effect 1
function s.con1filter(c)
	return c:IsSetCard(0xf31) and c:IsType(TYPE_LINK) and c:IsFaceup()
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_MZONE,0,nil)
	return g>0
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_HAND,nil)
	local ct=Duel.GetFlagEffect(tp,id)
	if chk==0 then return #g>0 and ct>0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,1-tp,LOCATION_DECK)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_HAND,nil)
	local ct=Duel.GetFlagEffect(tp,id)
	if #g>0 and ct>0 then
		ct=Duel.AnnounceNumberRange(tp,1,math.min(ct,#g))
		local sg=g:RandomSelect(tp,ct)
		Duel.ConfirmCards(tp,sg)
		local ssg=aux.SelectUnselectGroup(sg,e,tp,0,#sg,aux.TRUE,1,tp,HINTMSG_TODECK)
		if #ssg>0 then
			Duel.SendtoDeck(ssg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			Duel.ShuffleDeck(1-tp)
			Duel.BreakEffect()
			Duel.Draw(1-tp,#ssg,REASON_EFFECT)
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetTargetRange(0,LOCATION_DECK)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_DRAW)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(0,1)
	Duel.RegisterEffect(e2,tp)
end

--effect 2
function s.tg2filter(c)
	return c:IsSetCard(0xf31)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,nil)
	local ct=Duel.GetMatchingGroupCount(s.tg2filter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 and ct>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,LOCATION_GRAVE)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,nil)
	local ct=Duel.GetMatchingGroupCount(s.tg2filter,tp,LOCATION_GRAVE,0,nil)
	if #g>0 and ct>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.TRUE,1,tp,HINTMSG_TODECK)
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
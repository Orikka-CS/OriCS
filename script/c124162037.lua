--비블리오션 디크립터 레무리아
local s,id=GetID()
function s.initial_effect(c)
	--fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x6f20),aux.FilterBoolFunctionEx(Card.IsRace,RACE_CYBERSE))
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp end)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c)
	return c:IsContinuousSpell() and c:IsAbleToDeck() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeTargetCard(ev,Group.CreateGroup())
	Duel.ChangeChainOperation(ev,s.op1op)
end
function s.op1op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tg1filter),tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
		Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end

--effect 2
function s.tg2filter(c)
	return c:IsSetCard(0x6f20) and c:IsFaceup()
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.tg2filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	local p=1-Duel.GetTurnPlayer()
	if chk==0 then return ct>0 and Duel.GetFieldGroupCount(p,LOCATION_DECK,0)>0 end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.tg2filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	local p=1-Duel.GetTurnPlayer()
	ct=math.min(ct,Duel.GetFieldGroupCount(p,LOCATION_DECK,0))
	if ct==0 then return end
	Duel.ConfirmDecktop(p,ct)
	Duel.SortDecktop(tp,p,ct)
end

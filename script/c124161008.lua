--성광형－기적의 스텔라
local s,id=GetID()
function s.initial_effect(c)
	--synchro
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),1,1,Synchro.NonTuner(nil),1,99)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DRAW)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con2)
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local gc=Duel.GetMatchingGroupCount(Card.IsPublic,tp,LOCATION_HAND,0,nil)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,gc+1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,gc+1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,gc,tp,LOCATION_HAND)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local gc=Duel.GetMatchingGroupCount(Card.IsPublic,tp,LOCATION_HAND,0,nil)
	if Duel.Draw(tp,gc+1,REASON_EFFECT)>1 then
		gc=Duel.GetMatchingGroupCount(Card.IsPublic,tp,LOCATION_HAND,0,nil)
		if gc>0 then
			Duel.BreakEffect()
			local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
			local sg=aux.SelectUnselectGroup(g,e,tp,gc,gc,nil,1,tp,HINTMSG_TODECK)
			Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end

--effect 2
function s.con2filter(c,e,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_HAND) and c:IsSetCard(0xf20) and not c:IsPublic()
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.con2filter,1,nil,e,tp)
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk,re)
	local c=e:GetHandler()
	local g=eg:Filter(s.con2filter,nil,e,tp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONFIRM)
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(tp)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and e:GetHandler():GetFlagEffect(id)==0 end
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end
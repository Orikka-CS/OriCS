--용염의 신벌
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetCondition(s.con1)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)	
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
s.listed_names={id-5,id}
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local p,loct=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return loct&(LOCATION_HAND+LOCATION_GRAVE)~=0 and p~=tp and Duel.IsChainNegatable(ev)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckLPCost(tp,1000)
	end
	Duel.PayLPCost(tp,1000)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(s.ocon21)
	e1:SetOperation(s.oop21)
	Duel.RegisterEffect(e1,tp)
end
function s.onfil21(c)
	return c:IsFaceup() and (c:IsRace(RACE_FAIRY) or c:IsType(TYPE_COUNTER)) and c:IsAbleToDeck()
end
function s.ocon21(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.onfil21,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
end
function s.oofil21(c)
	return c:IsSSetable() and c:IsFaceup() and c:IsType(TYPE_COUNTER) and not c:IsCode(id)
end
function s.oop21(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.onfil21,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
	if #g==3 then
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
		Duel.Recover(tp,1500,REASON_EFFECT)
		if g:IsExists(Card.IsCode,1,nil,id-5) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=Duel.SelectMatchingCard(tp,s.oofil21,tp,LOCATION_REMOVED,0,0,1,nil)
			if #sg>0 then
				Duel.HintSelection(sg)
				Duel.SSet(tp,sg)
			end
		end
	end
end
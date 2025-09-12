--일광형－혜안의 솔라리스
local s,id=GetID()
function s.initial_effect(c)
	--synchro
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),1,1,Synchro.NonTuner(nil),1,99)
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
	e2:SetCategory(CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PUBLIC)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.con3)
	e3:SetTargetRange(0,LOCATION_HAND)
	c:RegisterEffect(e3)
end

--effect 1
function s.cst1filter(c)
	return c:IsDiscardable(REASON_COST)
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DISCARD)
	Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD)
end

function s.tg1filter(c)
	return c:IsSetCard(0xf20) and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tg1filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		if Duel.SendtoHand(sg,nil,REASON_EFFECT) then
			Duel.BreakEffect()
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end

--effect 2
function s.cst2filter(c)
	return c:IsSetCard(0xf20) and not c:IsPublic()
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONFIRM)
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(tp)
end

function s.tg2ifilter(c)
	return c:IsPublic()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local gi=Duel.GetMatchingGroup(s.tg2ifilter,tp,LOCATION_HAND,0,nil)
	local go=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	if chk==0 then return #gi>0 and #go>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,go,#gi,1-tp,LOCATION_HAND)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local gi=Duel.GetMatchingGroup(s.tg2ifilter,tp,LOCATION_HAND,0,nil)
	local go=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	if #gi==0 or #go==0 then return end
	Duel.ConfirmCards(tp,go)
	local sg=aux.SelectUnselectGroup(go,e,tp,1,#gi,aux.TRUE,1,tp,HINTMSG_REMOVE)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)
	Duel.ShuffleHand(1-tp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabelObject(sg)
	e1:SetCondition(s.op2addcon)
	e1:SetOperation(s.op2addop)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
	sg:KeepAlive()
	local tc=sg:GetFirst()
	for tc in aux.Next(sg) do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end

function s.op2addfilter(c)
	return c:GetFlagEffect(id)>0
end

function s.op2addcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=e:GetLabel()
end

function s.op2addop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(s.op2addfilter,nil)
	g:DeleteGroup()
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end

--effect 3
function s.con3filter(c)
	return c:IsPublic() and c:IsSetCard(0xf20)
end

function s.con3(e)
	local tp=e:GetHandler():GetControler()
	return Duel.GetMatchingGroupCount(s.con3filter,tp,LOCATION_HAND,0,nil)>0
end
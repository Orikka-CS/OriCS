--페더록스 오스릭
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.cst1filter(c)
	return c:IsSetCard(0xf2c) and not c:IsPublic()
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

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #rg>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,1,0,0)
end

function s.op1filter(c)
	return c:IsSetCard(0xf2c) and c:IsTrap() and c:IsSSetable()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #rg>0 then
		local rsg=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE):GetFirst()
		if Duel.Remove(rsg,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)>0 and rsg:IsLocation(LOCATION_REMOVED) and not rsg:IsReason(REASON_REDIRECT) then
			Duel.BreakEffect()
			Duel.ReturnToField(rsg)
			local g=Duel.GetMatchingGroup(s.op1filter,tp,LOCATION_DECK,0,nil)
			if rsg:IsControler(tp) and rsg:IsType(TYPE_XYZ) and #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.BreakEffect()
				local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SET)
				Duel.SSet(tp,sg)
			end
		end
	end
end

--effect 2
function s.cst2filter(c)
	return c:IsSetCard(0xf2c) and not c:IsCode(id) and c:IsAbleToRemoveAsCost()
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_GRAVE,0,c)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,LOCATION_GRAVE)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
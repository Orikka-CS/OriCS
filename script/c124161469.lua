--브릿지버스터 데몰리션
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.cst1filter(c)
	return c:IsSetCard(0xf3e) and c:IsAbleToGraveAsCost()
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_HAND,0,e:GetHandler())
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(sg,REASON_COST)
end

function s.tg1filter(c)
	return c:IsAbleToGrave()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_HAND,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,#g-1)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_HAND,nil)
	if #g>0 then
		if Duel.SendtoGrave(g,REASON_EFFECT)>0 then
			local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
			if ct>1 and Duel.IsPlayerCanDraw(1-tp,ct-1) then
				Duel.BreakEffect()
				Duel.Draw(1-tp,ct-1,REASON_EFFECT)
			end
		end
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(1-tp)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,tp)>0
end

function s.cst2filter(c)
	return c:IsSetCard(0xf3e) and c:IsAbleToRemoveAsCost()
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
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
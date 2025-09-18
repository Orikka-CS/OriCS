--[ Taiyaki ]
local s,id=GetID()
function s.initial_effect(c)
	
	RevLim(c)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRainbowFishCard),4,2)
	
	local e1=MakeEff(c,"STo")
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"STo")
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
	
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Group.CreateGroup()
	for i=1,3 do
		local token=Duel.CreateToken(tp,CARD_RAINBOW_FISH)
		g:AddCard(token)
	end
	Duel.DisableShuffleCheck()
	Duel.SendtoDeck(g,nil,1,REASON_RULE)
	Duel.Overlay(c,g)
end

function s.cost2f(c)
	return c:IsCode(CARD_RAINBOW_FISH) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cost2f,tp,LOCATION_MZONE|LOCATION_GRAVE,0,3,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cost2f,tp,LOCATION_MZONE|LOCATION_GRAVE,0,3,3,c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local op=Duel.SelectEffect(tp,
		{true,aux.Stringid(id,0)},
		{true,aux.Stringid(id,1)})
	if op==1 then
		local token=Duel.CreateToken(tp,99970999)
		Duel.SendtoHand(token,nil,REASON_EFFECT)
	else
		local g=Group.CreateGroup()
		for i=1,2 do
			local token=Duel.CreateToken(tp,CARD_RAINBOW_FISH)
			g:AddCard(token)
		end
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end

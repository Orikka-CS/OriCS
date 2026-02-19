--체어라키 패스키
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_TOGRAVE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c)
	return c:IsSetCard(0xf32) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.tg1xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetMatchingGroupCount(s.tg1filter,tp,LOCATION_DECK,0,nil)>0
	local b2=Duel.IsPlayerCanDiscardDeck(tp,1)
	local b3=Duel.GetMatchingGroupCount(s.tg1xyzfilter,tp,LOCATION_MZONE,0,nil)>0
	if chk==0 then return b1 or b2 or b3 or true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,900)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleDeck(tp)
			Duel.BreakEffect()
		end
	end
	if Duel.DiscardDeck(tp,1,REASON_EFFECT)>0 then
		Duel.DisableShuffleCheck()
		Duel.BreakEffect()
	end
	if c:IsRelateToEffect(e) then
		local xg=Duel.GetMatchingGroup(s.tg1xyzfilter,tp,LOCATION_MZONE,0,nil)
		if #xg>0 then
			local sg=aux.SelectUnselectGroup(xg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_FACEUP)
			local tc=sg:GetFirst()
			if tc and not tc:IsImmuneToEffect(e) then
				Duel.Overlay(tc,c)
				c:CancelToGrave()
				Duel.BreakEffect()
			end
		end
	end
	Duel.Recover(tp,900,REASON_EFFECT)
end

--effect 2
function s.cst2filter(c)
	return c:IsSetCard(0xf32) and c:IsType(TYPE_XYZ) and c:IsFacedown()
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and #g>0 end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONFIRM):GetFirst()
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleExtra(tp)
	e:SetLabel(sg:GetRank())
end

function s.tg2filter(c)
	return c:IsSetCard(0xf32) and c:HasLevel() and c:IsFaceup()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,0,nil)
	local rk=e:GetLabel(e)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(rk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
--블록체인 키옌
--Blockchain Kiyen
local s,id=GetID()
s.toss_coin=true
--Duel.LoadScript("blockchain.lua")
local B=Blockchain
function s.initial_effect(c)
	c:EnableReviveLimit()
	B.Init(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.searchcost)
	e1:SetTarget(s.searchtarget)
	e1:SetOperation(s.searchop)
	c:RegisterEffect(e1)
	B.AddCoinQuick(c,id,s.coinop,CATEGORY_COIN|CATEGORY_DRAW|CATEGORY_RELEASE|CATEGORY_DISABLE,1)
	B.AddReleasedRitual(c,id,2)
end
s.listed_series={0x6d72}
s.listed_names={99971089}
function s.release_filter(c,e,tp,reason)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and B.CanRelease(c,e,tp,reason)
end
function s.searchcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsLocation(LOCATION_HAND) and B.CanRelease(c,e,tp,REASON_COST)
		and Duel.IsExistingMatchingCard(s.release_filter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,c,e,tp,REASON_COST) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.release_filter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,c,e,tp,REASON_COST)
	g:AddCard(c)
	B.Release(g,REASON_COST,tp)
end
function s.search_filter(c)
	return B.IsSetCard(c) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.searchtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.search_filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.searchop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.search_filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		if Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
function s.spfilter(c,e,tp)
	return B.IsSetCard(c) and c:IsMonster() and c:IsFaceup()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.delayed_summon(e,tp)
	e:Reset()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil,e,tp)
	if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,4)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,1,nil)
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
function s.coinop(e,tp)
	local ctx=B.Context(e)
	if B.Toss(e,tp)==COIN_HEADS then
		Duel.Draw(tp,2,REASON_EFFECT)
		local g=Duel.GetMatchingGroup(s.release_filter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,nil,e,tp,REASON_EFFECT)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local ct=math.min(2,#g)
			B.Release(g:Select(tp,ct,ct,nil),REASON_EFFECT,tp)
		end
		if ctx.previous_effect and Duel.IsChainDisablable(ctx.previous_index) then
			Duel.NegateEffect(ctx.previous_index)
		end
	else
		local de=Effect.CreateEffect(e:GetHandler())
		de:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		de:SetCode(EVENT_PHASE|PHASE_STANDBY)
		de:SetCountLimit(1)
		if Duel.IsPhase(PHASE_STANDBY) then
			de:SetLabel(Duel.GetTurnCount())
			de:SetCondition(function(e) return Duel.GetTurnCount()>e:GetLabel() end)
		end
		de:SetOperation(s.delayed_summon)
		--During a Standby Phase, the current phase must not consume the
		--effect intended for the next Standby Phase.
		de:SetReset(RESET_PHASE|PHASE_STANDBY,Duel.IsPhase(PHASE_STANDBY) and 2 or 1)
		Duel.RegisterEffect(de,tp)
		if ctx.responded then
			--Official Droll & Lock Bird uses both codes: deck additions and draws.
			local ne=Effect.CreateEffect(e:GetHandler())
			ne:SetType(EFFECT_TYPE_FIELD)
			ne:SetCode(EFFECT_CANNOT_TO_HAND)
			ne:SetTargetRange(0,LOCATION_DECK)
			ne:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(ne,tp)
			local nd=Effect.CreateEffect(e:GetHandler())
			nd:SetType(EFFECT_TYPE_FIELD)
			nd:SetCode(EFFECT_CANNOT_DRAW)
			nd:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			nd:SetTargetRange(0,1)
			nd:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(nd,tp)
		end
	end
end

--블록체인 블랑
local s,id=GetID()
s.toss_coin=true
--Duel.LoadScript("blockchain.lua")
local B=Blockchain
s.listed_series={B.SET}
s.listed_names={B.INTERCONNECTION}
function s.initial_effect(c)
	c:EnableReviveLimit()
	B.Init(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	B.AddCoinQuick(c,id,s.coinop,CATEGORY_TOHAND|CATEGORY_SEARCH|CATEGORY_TOGRAVE|CATEGORY_REMOVE)
	B.AddReleasedRitual(c,id)
end
function s.monfilter(c)
	return c:IsSetCard(B.SET) and c:IsMonster() and c:IsAbleToHand()
end
function s.stfilter(c)
	return c:IsSetCard(B.SET) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.gyfilter(c)
	return c:IsSetCard(B.SET) and c:IsMonster() and c:IsAbleToGrave()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.monfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,g)
	local rg=Duel.GetMatchingGroup(B.HandFieldReleaseFilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,nil,e,tp,REASON_EFFECT)
	if #rg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		B.Release(rg:Select(tp,1,1,nil),REASON_EFFECT,tp)
	end
end
function s.coinop(e,tp)
	local ctx=B.Context(e)
	if B.Toss(e,tp)==COIN_HEADS then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then Duel.ConfirmCards(1-tp,g) end
		if ctx.previous_effect then
			local pe=ctx.previous_effect
			local cid=ctx.previous_chain_id
			local ie=Effect.CreateEffect(e:GetHandler())
			ie:SetType(EFFECT_TYPE_FIELD)
			ie:SetCode(EFFECT_IMMUNE_EFFECT)
			ie:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
			ie:SetValue(function(ie,re)
				return re==pe and Duel.GetCurrentChain()>0 and Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)==cid
			end)
			ie:SetReset(RESET_CHAIN)
			Duel.RegisterEffect(ie,tp)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
		local rc=ctx.response_card
		if ctx.responded and rc and rc:GetFieldID()==ctx.response_field_id and rc:IsAbleToRemove() then
			Duel.Remove(rc,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end

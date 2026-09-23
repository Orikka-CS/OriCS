--블록체인 아스트라
--Blockchain Astra
local s,id=GetID()
--Duel.LoadScript("blockchain.lua")
local B=Blockchain
function s.initial_effect(c)
	B.Init(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Native Second Coin Toss protocol, restricted to our archetype and GY.
	--Canonical: ProjectIgnis/CardScripts official/c36562627.lua.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TOSS_COIN_NEGATE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.coincon)
	e2:SetOperation(s.coinop)
	c:RegisterEffect(e2)
end
s.listed_series={0x6d72}
s.listed_names={99971089}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetDecktopGroup(tp,5)
	if chk==0 then return #g==5 and g:FilterCount(B.CanRelease,nil,e,tp,REASON_COST)==5 end
	B.Release(g,REASON_COST,tp)
end
function s.thfilter(c)
	return c:IsCode(99971089) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.operation(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		if B.HasTossed(tp) and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
function s.coincon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and re and B.IsSetCard(re:GetHandler()) and Duel.GetFlagEffect(tp,id)==0
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	--Shared player flag prevents another Astra copy or this nested toss
	--from consuming a second retry during the same turn.
	if Duel.GetFlagEffect(tp,id)>0 or not Duel.SelectEffectYesNo(tp,e:GetHandler()) then return end
	Duel.Hint(HINT_CARD,0,id)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	Duel.TossCoin(tp,ev)
end

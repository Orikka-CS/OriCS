--붉은 실이 축복하는 운명적 여정
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0xc00))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,1})
	c:RegisterEffect(e2)
end
s.listed_series={0xc00}
s.listed_names={id}
function s.ofil1(c)
	return c:IsSetCard(0xc00) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.ofil1,tp,LOCATION_DECK,0,0,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
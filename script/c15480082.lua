--광성의 의식
local s,id=GetID()
function s.initial_effect(c)
	Ritual.AddProcEqual(c,s.tfil1,nil,nil,nil,nil,nil,nil,LOCATION_HAND|LOCATION_GRAVE):SetCountLimit(1,id)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
s.listed_names={15480003}
s.listed_series={0xffe}
function s.tfil1(c)
	return c:IsCode(15480003) and c:IsRitualMonster()
end
function s.tfil2(c)
	return c:IsSetCard(0xffe) and c:IsAbleToHand()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil2,tp,LOCATION_DECK,0,2,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tfil2,tp,LOCATION_DECK,0,nil)
	if #g<2 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:Select(tp,2,2,nil)
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,sg)
end
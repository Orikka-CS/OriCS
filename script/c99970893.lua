--[ Plague ]
local s,id=GetID()
function s.initial_effect(c)

	local e9=MakeEff(c,"S","M")
	e9:SetCode(EFFECT_IMMUNE_EFFECT)
	e9:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e9:SetValue(function(e,te) return te:GetHandler():IsCode(CARD_PESTILENCE) end)
	c:RegisterEffect(e9)
	
	local e8=MakeEff(c,"F","M")
	e8:SetCode(EFFECT_CHANGE_CODE)
	e8:SetTargetRange(0,LOCATION_MZONE)
	e8:SetValue(CARD_PESTILENCE)
	e8:SetTarget(s.tar8)
	c:RegisterEffect(e8)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	
end

function s.tar8(e,c)
	return c:IsAttackAbove(2000) and c:IsFaceup()
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x5d6f) and c:IsMonster() and c:IsAbleToHandAsCost()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_COST)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

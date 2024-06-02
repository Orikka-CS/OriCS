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
	e8:SetTargetRange(0,LOCATION_ONFIELD)
	e8:SetValue(CARD_PESTILENCE)
	e8:SetTarget(s.tar8)
	c:RegisterEffect(e8)
	
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	
end

function s.tar8(e,c)
	return e:GetHandler():GetColumnGroup(1,1):Sub(e:GetHandler():GetColumnGroup()):IsContains(c)
end

function s.thfilter(c)
	return c:IsSetCard(0x5d6f) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

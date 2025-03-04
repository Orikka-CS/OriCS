--[ Anemoi ]
local s,id=GetID()
function s.initial_effect(c)

	YuL.Activate(c)
	
	local e1=MakeEff(c,"I","S")
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetCL(1,id)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)

	local e2=MakeEff(c,"FC","S")
	e2:SetCode(EVENT_CHAINING)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)

	local e3=MakeEff(c,"STo")
	e3:SetCode(EVENT_TO_HAND)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCL(1,{id,1})
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)
	
end

function s.tar1fil(c)
	return c:IsSetCard(0xad70) and c:IsMonster() and c:IsAbleToGrave()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar1fil,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tar1fil,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if ep==tp and re:IsActiveType(TYPE_MONSTER) and rc:IsSetCard(0xad70) then
		Duel.SetChainLimit(function(e,rp,tp) return tp==rp end)
	end
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_EFFECT>0
end
function s.tar3fil(c)
	return (c:IsCode(99970559,99970563) or (not c:IsCode(id) and c:IsSetCard(0xad70) and c:IsSpellTrap())) and c:IsAbleToHand()
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar3fil,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tar3fil,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--[ Heishou Pack ]
local s,id=GetID()
function s.initial_effect(c)

	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsCode,99971041))
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetTarget(s.desreptg)
	c:RegisterEffect(e5)
	
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(Cost.SelfToDeck)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	
end

function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tg=c:GetEquipTarget()
	if chk==0 then return tg 
		and tg:IsReason(REASON_BATTLE|REASON_EFFECT) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		if #g>0 then 
			Duel.BreakEffect()
			Duel.Hint(HINT_CARD,0,id)
			Duel.Destroy(g,REASON_EFFECT)
		end
		return true
	else return false end
end

function s.tar1fil(c,e,tp)
	return (c:IsCode(99971041) or c:IsSetCard(0xad71)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.tar1fil,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tar1fil),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end

--하얀 실: 위선자
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.con1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_COST)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SPSUMMON_COST)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.cost4)
	e4:SetTarget(s.tar4)
	e4:SetOperation(s.op4)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e6:SetCountLimit(1,{id,1})
	e6:SetCost(s.cost6)
	e6:SetTarget(s.tar6)
	e6:SetOperation(s.op6)
	c:RegisterEffect(e6)
end
function s.con1(e,c,minc)
	if c==nil then
		return true
	end
	return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.ocon21)
	e1:SetValue(0)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
function s.ocon21(e)
	local c=e:GetHandler()
	return c:GetMaterialCount()==0
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(0)
	e1:SetReset(RESET_EVENT|(RESETS_STANDARD|RESET_DISABLE)&~(RESET_TOFIELD|RESET_LEAVE))
	c:RegisterEffect(e1)
end
function s.cfil4(c,tp)
	return (c:IsControler(tp) or false)
		and c:IsAbleToGraveAsCost()
end
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfil4,tp,LOCATION_HAND,LOCATION_HAND,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfil4,tp,LOCATION_HAND,0,1,1,nil,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tfil4(c,e,tp,ec)
	return c:IsSetCard(0xc01) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and not c:IsCode(id)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.tfil4,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tfil4),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
function s.cfil6(c,tp)
	return ((c:IsControler(tp) and c:IsSetCard(0xc01)) or false)
		and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function s.cost6(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemoveAsCost()
			and Duel.IsExistingMatchingCard(s.cfil6,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,c,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfil6,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,c,tp)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.tfil6(c)
	return c:IsSetCard(0xc01) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.tar6(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil6,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.op6(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tfil6),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
		if #sg>0 then
			Duel.HintSelection(sg)
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
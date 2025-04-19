--네온 리제
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cost2)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
function s.nfil1(c)
	return c:IsSetCard(0xffe) and c:IsFaceup()
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.nfil1,tp,LOCATION_MZONE,0,1,nil)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.cfil2(c)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_RITUAL+TYPE_XYZ+TYPE_SYNCHRO+TYPE_FUSION+TYPE_PENDULUM+TYPE_LINK)
		and c:IsAbleToRemoveAsCost()
end
function s.cfun2(sg,e,tp,mg)
	return sg:IsExists(s.cffil21,1,nil,sg) and Duel.IsExistingMatchingCard(s.tfil2,tp,LOCATION_EXTRA,0,1,sg,e,tp,sg)
end
function s.cffil21(c,sg)
	if c:IsType(TYPE_RITUAL) then
		sg:RemoveCard(c)
		local res=sg:IsExists(s.cffil22,1,nil,sg)
		sg:AddCard(c)
		return res
	end
	return false
end
function s.cffil22(c,sg)
	if c:IsType(TYPE_XYZ) then
		sg:RemoveCard(c)
		local res=sg:IsExists(s.cffil23,1,nil,sg)
		sg:AddCard(c)
		return res
	end
	return false
end
function s.cffil23(c,sg)
	if c:IsType(TYPE_SYNCHRO) then
		sg:RemoveCard(c)
		local res=sg:IsExists(s.cffil24,1,nil,sg)
		sg:AddCard(c)
		return res
	end
	return false
end
function s.cffil24(c,sg)
	if c:IsType(TYPE_FUSION) then
		sg:RemoveCard(c)
		local res=sg:IsExists(s.cffil25,1,nil,sg)
		sg:AddCard(c)
		return res
	end
	return false
end
function s.cffil25(c,sg)
	if c:IsType(TYPE_PENDULUM) then
		sg:RemoveCard(c)
		local res=sg:IsExists(s.cffil26,1,nil)
		sg:AddCard(c)
		return res
	end
	return false
end
function s.cffil26(c)
	if c:IsType(TYPE_LINK) then
		return true
	end
	return false
end
function s.tfil2(c,e,tp,sg)
	local ec=e:GetHandler()
	return c:IsCode(15480034) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial()
		and Duel.GetLocationCountFromEx(tp,tp,sg and (sg+ec) or nil,c)>0
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(s.cfil2,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_MZONE+LOCATION_GRAVE,0,c)
	if chk==0 then
		return c:IsAbleToRemoveAsCost() and aux.SelectUnselectGroup(mg,e,tp,6,6,s.cfun2,0)
	end
	local sg=aux.SelectUnselectGroup(mg,e,tp,6,6,s.cfun2,1,tp,HINTMSG_REMOVE,s.cfun2)+c
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.tfil2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
		g:GetFirst():CompleteProcedure()
	end
end

--헤스티아의 불을 다시 훔치는 프로메테우스
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSquareProcedure(c)
	local e1=MakeEff(c,"S","M")
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetCondition(s.con1)
	e1:SetValue(ATTRIBUTE_DIVINE)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCL(1,id)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"STo")
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetCL(1,id)
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)
end
s.square_mana={ATTRIBUTE_FIRE,ATTRIBUTE_EARTH,ATTRIBUTE_WIND,ATTRIBUTE_WATER}
s.custom_type=CUSTOMTYPE_SQUARE
function s.con1(e)
	local c=e:GetHandler()
	return c:IsNormalSummoned() or c:IsSummonType(SUMMON_TYPE_SQUARE)
end
function s.tfil2(c,e,tp)
	return c:IsCustomType(CUSTOMTYPE_SQUARE) and c:IsAttribute(ATTRIBUTE_FIRE+ATTRIBUTE_EARTH+ATTRIBUTE_WIND+ATTRIBUTE_WATER) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLoc("G") and s.tfil2(chkc,e,tp)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil2,tp,"G",0,1,nil,e,tp) and Duel.GetLocCount(tp,"M")>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.STarget(tp,s.tfil2,tp,"G",0,1,1,nil,e,tp)
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then
		return
	end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=MakeEff(c,"S")
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=MakeEff(c,"F")
		Duel.SpecialSummonComplete()
	end
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SQUARE)
end
function s.tfil3(c)
	return c:IsCustomType(CUSTOMTYPE_SQUARE) and c:IsAttribute(ATTRIBUTE_FIRE+ATTRIBUTE_EARTH+ATTRIBUTE_WIND+ATTRIBUTE_WATER) and c:CanSummonOrSet(true,nil)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil3,tp,"HM",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SMCard(tp,s.tfil3,tp,"HM",0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.SummonOrSet(tp,tc,true,nil)
	end
end
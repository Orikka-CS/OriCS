--ÂªÀº ¹ã º°ÀÇ ²Þ
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"F","H")
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.con1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetCL(1,id)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"STo")
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCL(1,{id,1})
	WriteEff(e4,4,"TO")
	c:RegisterEffect(e4)
end
function s.nfil1(c)
	return not c:IsRace(RACE_FAIRY) or not c:IsAttribute(ATTRIBUTE_FIRE) or c:IsFacedown()
end
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return not Duel.IEMCard(s.nfil1,tp,"M",0,1,nil) and Duel.GetLocCount(tp,"M")>0
end
function s.tfil2(c)
	return ((c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_FIRE))
		or (c:IsSetCard("¹ÌÄ«") and c:IsType(TYPE_SPELL+TYPE_TRAP)))
		and c:IsAbleToHand()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil2,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil2,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.tfil4(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLoc("G") and s.tfil4(chkc,e,tp)
	end
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0 and Duel.IETarget(s.tfil4,tp,"G",0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.STarget(tp,s.tfil4,tp,"G",0,1,1,nil,e,tp)
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget(e)
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
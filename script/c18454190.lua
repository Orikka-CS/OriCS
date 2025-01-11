--아이시스 오브 툰드라
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"F","H")
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.con1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"SC")
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	WriteEff(e2,2,"O")
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"S")
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(s.con4)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"STo")
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	WriteEff(e5,5,"TO")
	c:RegisterEffect(e5)
	local e6=MakeEff(c,"STo")
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetCL(1,id)
	WriteEff(e6,6,"TO")
	c:RegisterEffect(e6)
end
s.listed_names={15259703}
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.GetLocCount(tp,"M")>0 and Duel.IEMCard(aux.FaceupFilter(Card.IsCode,15259703),tp,"O",0,1,nil)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function s.nfil4(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
function s.con4(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IEMCard(s.nfil4,tp,0,"M",1,nil)
end
function s.tfil5(c,e,tp)
	return c:IsType(TYPE_TOON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsLoc("G") and chkc:IsControler(tp) and s.tfil5(chkc,e,tp)
	end
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0
			and Duel.IETarget(s.tfil5,tp,"G",0,1,nil,e,tp) and not c:IsStatus(STATUS_CHAINING)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.STarget(tp,s.tfil5,tp,"G",0,1,1,nil,e,tp)
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.tar6(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsStatus(STATUS_CHAINING)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op6(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
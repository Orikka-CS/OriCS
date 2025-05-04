--¸£ºí¶û ¿¡¹ÝÁ©¸°
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.con2)
	c:RegisterEffect(e2)
end
function s.tfil1(c,e,tp)
	return c:IsSetCard("¸£ºí¶û") and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"HG",0,1,nil,e,tp) and Duel.GetLocCount(1-tp,"M")>0
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"HG")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocCount(1-tp,"M")<=0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SMCard(tp,aux.NecroValleyFilter(s.tfil1),tp,"HG",0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_FACEUP)
	end
end
function s.nfil2(c)
	return c:IsFaceup() and c:IsSetCard("¸£ºí¶û")
end
function s.con2(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IEMCard(s.nfil2,tp,"O","O",1,nil)
end
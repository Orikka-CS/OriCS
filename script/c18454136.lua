--¸£ºí¶û Å¬¶ô¾÷
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCondition(Duel.IsMainPhase)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
end
function s.tfil1(c,e,tp)
	return c:IsSetCard("¸£ºí¶û") and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil,e,tp) and Duel.GetLocCount(1-tp,"M")>0
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"D")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocCount(1-tp,"M")<=0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_FACEUP)
	end
end
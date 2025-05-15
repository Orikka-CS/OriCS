--천상 피아니스트
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"I","M")
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCost(Cost.PayLP(1000))
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
end
function s.tfil1(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_TUNER) and c:IsLevelBelow(6)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"E",0,1,nil,e,tp)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"E")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SMCard(tp,s.tfil1,tp,"E",0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetDescription(3207)
		tc:RegisterEffect(e1,true)
		local e2=MakeEff(c,"FC","M")
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCL(1)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		e2:SetOperation(s.oop12)
		tc:RegisterEffect(e2)
	end
end
function s.oop12(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
end
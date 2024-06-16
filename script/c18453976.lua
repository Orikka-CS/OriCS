--그대 이름은 불사조
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"E")
end
function s.ofil1(c)
	return c:IsSpecialSummonable(0) and c:IsCustomType(CUSTOMTYPE_BRAVE)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTR("M",0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(300)
	Duel.RegisterEffect(e1,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SMCard(tp,s.ofil1,tp,"E",0,0,1,nil)
	if #sg>0 then
		Duel.BreakEffect()
		Duel.SpecialSummonRule(tp,sg:GetFirst(),0)
	end
end
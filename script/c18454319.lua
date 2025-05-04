--범골의 용기
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","S")
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTR("M",0)
	e2:SetValue(200)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"F","S")
	e3:SetCode(EFFECT_UPDATE_BRAVE)
	e3:SetTR("M",0)
	e3:SetValue(200)
	c:RegisterEffect(e3)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"D")
end
function s.ofil1(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsSetCard("브레이브") or c:IsSetCard("버닝"))
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocCount(tp,"M")>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SMCard(tp,s.ofil1,tp,"D",0,0,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			local e1=MakeEff(c,"F","M")
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetAbsoluteRange(tp,1,0)
			e1:SetTarget(s.otar11)
			tc:RegisterEffect(e1)
			Duel.SpecialSummonComplete()
		end
	end
end
function s.otar11(e,c)
	local tc=e:GetHandler()
	return c:GetAttack()>tc:GetAttack()
end
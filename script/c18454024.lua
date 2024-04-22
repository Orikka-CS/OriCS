--새천년마과학신세계미래천왕강림
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","F")
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTR("M","M")
	e2:SetTarget(s.tar2)
	e2:SetValue(600)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetTarget(s.tar4)
	e4:SetValue(300)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
	local e6=MakeEff(c,"FTo","F")
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e6:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e6:SetCL(1,0,EFFECT_COUNT_CODE_SINGLE)
	WriteEff(e6,6,"TO")
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_LEAVE_GRAVE)
	c:RegisterEffect(e7)
end
function s.ofil1(c)
	return c:IsSetCard("마과학") and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.ofun1(g)
	return g:GetClassCount(Card.GetLevel)==2
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GMGroup(s.ofil1,tp,"D",0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:SelectSubGroup(tp,s.ofun1,false,2,2)
	if #sg==2 then
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
function s.tar2(e,c)
	return c:IsSetCard("마과학") and c:IsLevel(3)
end
function s.tar4(e,c)
	return c:IsSetCard("마과학") and c:IsLevel(4)
end
function s.tfil6(c,e,tp)
	return ((c:IsOnField() and c:IsType(TYPE_SPELL+TYPE_TRAP)) or c:IsLoc("G"))
		and (c:IsAbleToRemove() or (c:IsSetCard("마과학") and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.GetLocCount(tp,"M")>0))
end
function s.tar6(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("OG") and s.tfil6(chkc,e,tp)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil6,tp,"OG",0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.STarget(tp,s.tfil6,tp,"OG",0,1,1,nil,e,tp)
	Duel.SPOI(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.op6(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then
		return
	end
	if tc:IsSetCard("마과학") and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocCount(tp,"M")>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		return
	end
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
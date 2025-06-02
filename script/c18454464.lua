--sparkle.exe: Shortcut dreams will get you far
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","S")
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetTR(1,0)
	e2:SetTarget(s.tar2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"STo")
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e3:SetCL(1,{id,1})
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
end
function s.tar2(e,c)
	return c:IsSummonType(SUMMON_TYPE_SEQUENCE) and c:IsSetCard("sparkle.exe")
end
function s.tfil3(c)
	return c:IsSetCard("sparkle.exe") and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.tfil3,tp,"D",0,1,nil) and Duel.GetLocCount(tp,"S")>0
	end
	Duel.SPOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
	Duel.SPOI(0,CATEGORY_TOGRAVE,nil,1,tp,"D")
	Duel.SOI(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil3,tp,"D",0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		aux.ToHandOrElse(tc,tp)
		if tc:IsLoc("HG") and c:IsRelateToEffect(e) and Duel.GetLocCount(tp,"S")>0 then
			Duel.BreakEffect()
			Duel.MoveToField(c,tp,tp,LSTN("S"),POS_FACEUP,true)
		end
	end
end
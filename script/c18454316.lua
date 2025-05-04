--매크로 코스모스가 부르는 소리
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","S")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCL(1,id)
	WriteEff(e2,2,"NCTO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"SC")
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	WriteEff(e3,3,"O")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"SC")
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	WriteEff(e4,4,"O")
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetCardTargetCount()==0
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckLPCost(tp,1000)
	end
	Duel.PayLPCost(tp,1000)
end
function s.tfil2(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("R") and s.tfil2(chkc,e,tp)
	end
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0 and Duel.IETarget(s.tfil2,tp,"R","R",1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.STarget(tp,s.tfil2,tp,"R","R",1,1,nil,e,tp)
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		c:SetCardTarget(tc)
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED_FACEDOWN)
		tc:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsDisabled() then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabelObject():GetLabel()~=0 then
		return
	end
	local tc=c:GetFirstCardTarget()
	if tc and tc:IsLoc("M") then
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end
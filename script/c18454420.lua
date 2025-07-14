--모듈러스 모듈라이즈!
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetCost(aux.RemainFieldCost)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.con2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"FTo","S")
	e3:SetCode(EVENT_EQUIP)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"STo")
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_EQUIP)
	WriteEff(e4,4,"NCTO")
	c:RegisterEffect(e4)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.afil1)
end
function s.afil1(c)
	return c:IsType(TYPE_MODULE) or not c:IsLocation(LOCATION_EXTRA)
end
s.listed_names={18452797}
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0
			and Duel.IEMCard(Card.IsCanBeSpecialSummoned,tp,"H",0,1,nil,e,0,tp,false,false)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"H")
	Duel.SOI(0,CATEGORY_EQUIP,c,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,rrp)
	local c=e:GetHandler()
	if Duel.GetLocCount(tp,"M")<=0 then
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			c:CancelToGrave(false)
		end
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SMCard(tp,Card.IsCanBeSpecialSummoned,tp,"H",0,1,1,nil,e,0,tp,false,false)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			return
		end
		Duel.Equip(tp,c,tc)
		local e1=MakeEff(tc,"S")
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(s.oval11)
		c:RegisterEffect(e1)
		local e2=MakeEff(c,"S")
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		e2:SetValue(18452797)
		c:RegisterEffect(e2)
		Duel.SpecialSummonComplete()
	elseif c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
		c:CancelToGrave(false)
	end
end
function s.oval11(e,c)
	return e:GetOwner()==c
end
function s.con2(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(tp,LSTN("M"),0)==0 and Duel.GetFieldGroupCount(tp,0,LSTN("M"))>0
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsContains(c)
end
function s.tfil3(c)
	return c:IsType(TYPE_MODULE) and c:IsSpecialSummonable(SUMMON_TYPE_MODULE)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then
		local e1=MakeEff(c,"F","M")
		e1:SetCode(EFFECT_MUST_BE_MMATERIAL)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		ec:RegisterEffect(e1)
		local res=Duel.IEMCard(s.tfil3,tp,"E",0,1,nil)
		e1:Reset()
		return res
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"E")
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if c:IsRelateToEffect(e) and ec then
		local e1=MakeEff(c,"F","M")
		e1:SetCode(EFFECT_MUST_BE_MMATERIAL)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_CHAIN)
		ec:RegisterEffect(e1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SMCard(tp,s.tfil3,tp,"E",0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.SpecialSummonRule(tp,tc,SUMMON_TYPE_MODULE)
		end
	end
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget() or c:GetPreviousEquipTarget()
	return ec and ec:IsReason(REASON_MODULE) and ec:IsReason(REASON_MATERIAL)
end
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
	end
	Duel.ConfirmCards(1-tp,c)
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.ctar41)
	Duel.RegisterEffect(e1,tp)
end
function s.ctar41(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_MODULE)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc==e:GetLabelObject() and chkc:IsLoc("M") and chkc:IsFaceup() and chkc:IsType(TYPE_MODULE)
	end
	if chk==0 then
		local ec=c:GetEquipTarget() or c:GetPreviousEquipTarget()
		local mc=nil
		if ec then
			mc=ec:GetReasonCard()
			e:SetLabelObject(mc)
		end
		return mc and mc:IsFaceup() and mc:IsCanBeEffectTarget(e) and Duel.GetLocCount(tp,"S")>0
	end
	local mc=e:GetLabelObject()
	if mc then
		Duel.SetTargetCard(Group.FromCards(mc))
	end
	Duel.SOI(0,CATEGORY_EQUIP,c,1,0,0)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
		local e1=MakeEff(tc,"S")
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(s.oval11)
		c:RegisterEffect(e1)
		local e2=MakeEff(c,"S")
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		e2:SetValue(18452797)
		c:RegisterEffect(e2)
	end
end
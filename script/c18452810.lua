--FD-데피니션 다빈치
local m=18452810
local cm=_G["c"..m]
function cm.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddModuleProcedure(c,nil,nil,1,1,cm.pfun1)
	aux.AddCodeList(c,18452807,18452805)
	local e1=MakeEff(c,"FC")
	e1:SetCode(EVENT_ADJUST)
	WriteEff(e1,1,"NO")
	Duel.RegisterEffect(e1,0)
	local e2=MakeEff(c,"STo")
	e2:SetCode(m)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"I","M")
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_EQUIP)
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"I","S")
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	WriteEff(e4,4,"TO")
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"E")
	e5:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetValue(cm.val5)
	c:RegisterEffect(e5)
	local e6=MakeEff(c,"E")
	e6:SetCode(EFFECT_UPDATE_LEVEL)
	e6:SetValue(3)
	c:RegisterEffect(e6)
	local e7=MakeEff(c,"E")
	e7:SetCode(EFFECT_UPDATE_ATTACK)
	e7:SetValue(1000)
	c:RegisterEffect(e7)
	local e8=MakeEff(c,"E")
	e8:SetCode(EFFECT_UPDATE_DEFENSE)
	e8:SetValue(1000)
	c:RegisterEffect(e8)
	local e9=MakeEff(c,"E")
	e9:SetCode(EFFECT_IMMUNE_EFFECT)
	e9:SetValue(cm.val9)
	c:RegisterEffect(e9)
	local e10=MakeEff(c,"S")
	e10:SetCode(EFFECT_UNION_LIMIT)
	e10:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e10:SetValue(cm.val10)
	c:RegisterEffect(e10)
end
cm.listed_series={0x2d6}
function cm.pfun1(g)
	local tc=g:GetFirst()
	local ec=tc:GetEquipTarget()
	local sg=g:Clone()
	sg:AddCard(ec)
	return sg:IsExists(Card.IsModuleCode,1,nil,18452807) and sg:IsExists(Card.IsModuleCode,1,nil,18452805)
end
function cm.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetFlagEffectLabel(m+10000000)
	local loc=c:GetLocation()
	return not ct or loc~=ct
end
function cm.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetFlagEffectLabel(m+10000000)
	local loc=c:GetLocation()
	if not ct then
		c:RegisterFlagEffect(m+10000000,0,0,0,loc)
	end
	if loc~=ct then
		c:SetFlagEffectLabel(m+10000000,loc)
		if not c:IsStatus(STATUS_SUMMONING) then
			Duel.RaiseSingleEvent(c,m,c:GetReasonEffect(),c:GetReason(),c:GetReasonPlayer(),c:GetReasonPlayer(),0)
		end
	end
end
function cm.tfil2(c,e,tp)
	return c:IsSetCard(0x2d6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsLevel(6)
end
function cm.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLoc("G") and cm.tfil2(chkc,e,tp)
	end
	if chk==0 then
		return Duel.IETarget(cm.tfil2,tp,"G",0,1,nil,e,tp) and Duel.GetLocCount(tp,"M")>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.STarget(tp,cm.tfil2,tp,"G",0,1,1,nil,e,tp)
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"G")
end
function cm.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LSTN("R"))
		tc:RegisterEffect(e1)
	end
end
function cm.tfil3(c)
	local ct1,ct2=c:GetUnionCount()
	return c:IsSetCard(0x2d6) and c:IsFaceup() and not aux.IsCodeListed(c,18452807) and not aux.IsCodeListed(c,18452805) and ct2<1
end
function cm.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsLoc("M") and chkc:IsControler(tp) and cm.tfil3(chkc)
	end
	if chk==0 then
		return c:GetFlagEffect(m)<1 and Duel.GetLocCount(tp,"S")>0 and Duel.IETarget(cm.tfil3,tp,"M",0,1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.STarget(tp,cm.tfil3,tp,"M",0,1,1,c)
	Duel.SOI(0,CATEGORY_EQUIP,g,1,0,0)
	c:RegisterFlagEffect(m,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
function cm.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then
		return
	end
	if not tc:IsRelateToEffect(e) or not cm.tfil3(tc) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	if not Duel.Equip(tp,c,tc,false) then
		return
	end
	aux.SetUnionState(c)
end
function cm.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:GetFlagEffect(m)<1 and Duel.GetLocCount(tp,"M")>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:RegisterFlagEffect(m,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
function cm.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
	end
end
function cm.val5(e,re,r,rp)
	return r&(REASON_BATTLE+REASON_EFFECT)>0
end
function cm.val9(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:GetOwner()~=e:GetOwner() and te:IsActiveType(TYPE_SPELL)
end
function cm.val10(e,c)
	return (c:IsSetCard(0x2d6) and not aux.IsCodeListed(c,18452807) and not aux.IsCodeListed(c,18452805)) or e:GetHandler():GetEquipTarget()==c
end
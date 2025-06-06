--신천지의 총무 이바크
local s,id=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,nil,3,2,s.pfil1,aux.Stringid(id,0),2,s.pop1)
	c:EnableReviveLimit()
	local e1=MakeEff(c,"Qo","M")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCL(1,id)
	WriteEff(e1,1,"CO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"FTo","G")
	e3:SetCode(EVENT_DESTROY)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e3:SetCL(1,{id,1})
	WriteEff(e3,3,"N")
	WriteEff(e3,2,"TO")
	c:RegisterEffect(e3)
end
function s.pfil1(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard("신천지",lc,SUMMON_TYPE_XYZ,tp)
		and not c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp)
end
function s.pofil1(c)
	return c:IsSetCard("신천지") and c:IsType(TYPE_MONTSER) and c:IsReleasable()
end
function s.pop1(e,tp,chk)
	if chk==0 then
		return Duel.GetFlagEffect(tp,id)==0 and Duel.IEMCard(s.pofil1,tp,"D",0,1,nil)
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SMCard(tp,s.pofil1,tp,"D",0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST+REASON_RELEASE)
	return true
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	end
	c:CheckRemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetTR("MG","MG")
	e1:SetValue(ATTRIBUTE_LIGHT)
	e1:SetReset(RESET_PHASE+PHASE_END)
	--
	Duel.RegisterEffect(e1,tp)
	local e2=MakeEff(c,"F")
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTR("M","M")
	e2:SetTarget(s.otar12)
	e2:SetValue(s.oval12)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	local e3=MakeEff(c,"F")
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetTR("M","M")
	e3:SetTarget(s.otar13)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
	local e4=MakeEff(c,"FC")
	e4:SetCode(EVENT_ADJUST)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e4:SetLabelObject(g)
	e3:SetLabelObject(e4)
	e4:SetOperation(s.oop14)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)
end
function s.otar12(e,c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.otar13(e,c)
	local val=0
	local eset={c:IsHasEffect(18453801)}
	for _,te in pairs(eset) do
		local tval=te:GetValue()
		val=val-tval
	end
	local atk=c:GetAttack()
	if atk>0 and atk+val<=0 then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
	end
	return val
end
function s.tar4(e,c)
	if c:GetFlagEffect(id)>0 then
		local e1=MakeEff(e:GetHandler(),"S")
		e1:SetCode(EFFECT_ALICE_SCARLET)
		e1:SetValue(id)
		c:RegisterEffect(e1)
		local g=e:GetLabelObject():GetLabelObject()
		g:AddCard(c)
		return true
	end
	return false
end
function s.oop14(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tc=g:GetFirst()
	local sg=Group.CreateGroup()
	while tc do
		sg:AddCard(tc)
		local eset={tc:IsHasEffect(EFFECT_ALICE_SCARLET)}
		for _,te in pairs(eset) do
			local tval=te:GetValue()
			if tval==id then
				te:Reset()
			end
		end
		tc:ResetFlagEffect(id)
		tc=g:GetNext()
	end
	g:Sub(sg)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsLoc("G")
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocCount(tp,"M")>0
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(id-10000,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		local e1=MakeEff(c,"FC")
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCL(1)
		e1:SetLabel(fid)
		e1:SetCondition(s.ocon21)
		e1:SetOperation(s.oop21)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.onfil21(c)
	return c:IsLevel(3) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_PSYCHO)
end
function s.ocon21(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffectLabel(id-10000)~=e:GetLabel() then
		e:Reset()
		return false
	end
	return Duel.IEMCard(s.onfil21,tp,"D",0,1,nil)
end
function s.oop21(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SMCard(tp,s.onfil21,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.Overlay(c,g,true)
	end
end
function s.nfil3(c)
	return c:IsHasEffect(CARD_NEW_HEAVEN_AND_EARTH)
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.nfil3,1,nil)
end
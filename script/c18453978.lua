--광클마우스
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,4,2,s.pfil1,aux.Stringid(id,0),2,s.pop1)
	local e1=MakeEff(c,"Qo","M")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START+TIMING_MAIN_END)
	e1:SetCL(1)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	local e2=MakeEff(c,"Qo","G")
	e2:SetCode(EVENT_FREE_CHAIN)	
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"FC","M")
	e3:SetCode(EVENT_ADJUST)
	WriteEff(e3,3,"O")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"FC","M")
	e4:SetCode(EVENT_CHAIN_SOLVED)
	WriteEff(e4,4,"O")
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_BATTLED)
	WriteEff(e5,5,"O")
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EVENT_BECOME_TARGET)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	WriteEff(e6,6,"O")
	c:RegisterEffect(e6)
end
s.listed_names={18453902}
function s.pfil1(c)
	return c:IsFaceup() and c:IsCode(18453903)
end
function s.pfil2(c)
	return c:IsCode(18453902)
end
function s.pop1(e,tp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.pfil2,tp,"H",0,1,nil)
			and Duel.GetFlagEffect(tp,id)==0
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	local g=Duel.SMCard(tp,s.pfil2,tp,"H",0,1,1,nil)
	c:SetMaterial(g)
	Duel.Overlay(c,g)
	return true
end
function s.ofil3(c)
	return c:IsNegatable() and c:GetOwnerTargetCount()>0
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GMGroup(s.ofil3,tp,"O","O",nil)
	if #g>0 then
		local tc=g:GetFirst()
		while tc do
			local e1=MakeEff(c,"S")
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=MakeEff(c,"S")
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				local e3=MakeEff(c,"S")
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
			tc=g:GetNext()
		end
	end
end
function s.ofil4(c)
	return c:GetFlagEffect(id)>0
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g then
		return
	end
	local rg=g:Filter(Card.IsRelateToEffect,nil,re)
	if #rg==0 then
		return
	end
	for _,ch in ipairs({c:GetFlagEffectLabel(id+1)}) do
		if ch==ev then
			if (Duel.GetCurrentPhase()&(PHASE_DAMAGE|PHASE_DAMAGE_CAL))~=0 and not Duel.IsDamageCalculated() then
				local rc=rg:GetFirst()
				while rc do
					rc:RegisterEffect(id,RESET_PHASE|PHASE_DAMAGE|RESET_EVENT|RESETS_STANDARD,0,1)
					rc=rg:GetNext()
				end
			elseif not c:IsHasEffect(EFFECT_DISABLE) and not c:IsDisabled() then
				local tc=rg:GetFirst()
				while tc do
					if tc:IsNegatable() then
						local e1=MakeEff(c,"S")
						e1:SetCode(EFFECT_DISABLE)
						e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
						tc:RegisterEffect(e1)
						local e2=MakeEff(c,"S")
						e2:SetCode(EFFECT_DISABLE_EFFECT)
						e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
						e2:SetValue(RESET_TURN_SET)
						tc:RegisterEffect(e2)
						if tc:IsType(TYPE_TRAPMONSTER) then
							local e3=MakeEff(c,"S")
							e3:SetType(EFFECT_TYPE_SINGLE)
							e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
							e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
							e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
							tc:RegisterEffect(e3)
						end
					end
					tc=rg:GetNext()
				end
			end
			return			
		end
	end
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.ofil4,tp,LSTN("OGR"),LSTN("OGR"),nil)
	if #g>0 and not c:IsHasEffect(EFFECT_DISABLE) and not c:IsDisabled() then
		local tc=g:GetFirst()
		while tc do
			if tc:IsNegatable() then
				local e1=MakeEff(c,"S")
				e1:SetCode(EFFECT_DISABLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
				local e2=MakeEff(c,"S")
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				e2:SetValue(RESET_TURN_SET)
				tc:RegisterEffect(e2)
				if tc:IsType(TYPE_TRAPMONSTER) then
					local e3=MakeEff(c,"S")
					e3:SetType(EFFECT_TYPE_SINGLE)
					e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
					e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					tc:RegisterEffect(e3)
				end
			end
			tc=g:GetNext()
		end
	end
end
function s.op6(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id+1,RESET_CHAIN|RESET_EVENT|RESETS_STANDARD,0,1,ev)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.cfil1(c)
	return (c:GetType()==TYPE_TRAP or c:IsType(TYPE_QUICKPLAY)) and (c:IsCode(18453902) or c:ListsCode(18453902))
		and c:IsAbleToGraveAsCost()
		and c:CheckActivateEffect(false,true,true)~=nil
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
			and Duel.IEMCard(s.cfil1,tp,"D",0,1,nil)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.cfil1,tp,"D",0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then
		tg(e,tp,ceg,cep,cev,cre,cr,crp,1)
	end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then
		return
	end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then
		op(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToExtraAsCost()
	end
	Duel.SendtoDeck(c,nil,2,REASON_COST)
end
function s.tfil2(c,e,tp)
	return c:IsCode(18453903) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLoc("G") and s.tfil1(chkc,e,tp)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil2,tp,"G",0,1,nil,e,tp) and Duel.GetLocCount(tp,"M")>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.STarget(tp,s.tfil2,tp,"G",0,1,1,nil,e,tp)
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocCount(tp,"M")<1 then
		return
	end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
--sparkle.exe: Broken code, still let me in
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSequenceProcedure(c,nil,s.pfil1,1,99,s.pfil2,1,99,aux.TRUE,1,99)
	local e1=MakeEff(c,"Qo","H")
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DISABLE)
	e1:SetCL(1,id)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","M")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
end
function s.pfil1(tp,re,rp)
	local rc=re:GetHandler()
	return rc:IsSetCard("sparkle.exe")
end
function s.pfil2(tp,re,rp)
	return re:IsActiveType(TYPE_QUICKPLAY)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	if ev<=1 or rp==tp then
		return false
	end
	local cp=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_PLAYER)
	return cp==tp
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:IsPublic()
	end
	Duel.ConfirmCards(1-tp,c)
end
function s.tfil11(c)
	return c:IsType(TYPE_SPELL) and c:IsNegatable()
end
function s.tfil12(c)
	return c:IsSetCard("sparkle.exe")
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsOnField() and s.tfil11(chkc)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil11,tp,"O","O",1,nil) and Duel.IEMCard(s.tfil12,tp,"H",0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.STarget(tp,s.tfil11,tp,"O","O",1,1,nil)
	Duel.SOI(0,CATEGORY_DISABLE,g,1,0,0)
	Duel.SOI(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SMCard(tp,s.tfil1,tp,"H",0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)>0 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsNegatable() then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=MakeEff(c,"S")
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				local e3=e1:Clone()
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				tc:RegisterEffect(e3)
			end
		end
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()&(PHASE_MAIN1+PHASE_MAIN2)~=0
end
function s.tfil2(c)
	return c:IsSetCard("sparkle.exe") and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if c:IsSummonType(SUMMON_TYPE_SEQUENCE) then
			e:SetLabel(1)
		else
			e:SetLabel(0)
		end
		return Duel.IEMCard(s.tfil2,tp,"D",0,1,nil)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SMCard(tp,s.tfil2,tp,"D",0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SSet(tp,g)>0 and e:GetLabel()==1 then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
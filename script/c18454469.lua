--We're the Pomipomi.exe
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_CHAINING)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_CONTROL)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FTo","G")
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and Duel.IsChainNegatable(ev)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.nfil1(c)
	return c:IsFaceup() and c:IsSetCard("sparkle.exe")
end
function s.nfil1(c)
	return c:IsSetCard("sparkle.exe") and not c:IsPublic()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.cfil1,tp,"H",0,1,c) or Duel.IEMCard(s.nfil1,tp,"O",0,1,c)
	end
	local minct=1
	if Duel.IEMCard(s.nfil1,tp,"O",0,1,c) then
		minct=0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SMCard(tp,s.cfil1,tp,"H",0,minct,1,c)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	local rc=re:GetHandler()
	Duel.SOI(0,CATEGORY_NEGATE,eg,1,0,0)
	if rc:IsRelateToEffect(re) and rc:IsDestructable() then
		Duel.SOI(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	local cc=Duel.GetCurrentChain()
	if cc>2 then
		local p0=Duel.GetChainInfo(cc-2,CHAININFO_TRIGGERING_PLAYER)
		local p1=Duel.GetChainInfo(cc-1,CHAININFO_TRIGGERING_PLAYER)
		if p0==tp and p1~=tp then
			e:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_CONTROL)
		else
			e:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
		end
	else
		e:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) then
		if rc:IsRelateToEffect(re) then
			Duel.Destroy(eg,REASON_EFFECT)
		end
		local cc=Duel.GetCurrentChain()
		if cc>2 then
			local p0=Duel.GetChainInfo(cc-2,CHAININFO_TRIGGERING_PLAYER)
			local p1=Duel.GetChainInfo(cc-1,CHAININFO_TRIGGERING_PLAYER)
			if p0==tp and p1~=tp then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
				local g=Duel.SMCard(tp,Card.IsControlerCanBeChanged,tp,0,"M",0,1,nil)
				if #g>0 then
					Duel.HintSelection(g)
					Duel.GetControl(g,tp,PHASE_END,2)
				end
			end
		end
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	if ev<=2 then
		return false
	end
	local p0=Duel.GetChainInfo(ev-2,CHAININFO_TRIGGERING_PLAYER)
	local p1=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_PLAYER)
	return p0==tp and p1~=tp and rp==tp
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsSSetable()
	end
	Duel.SOI(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)>0 then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
--칙명의 왕궁
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FC","S")
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCL(1)
	WriteEff(e2,2,"O")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"FC","S")
	e3:SetCode(EVENT_ADJUST)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.CheckLPCost(tp,700) then
		Duel.PayLPCost(tp,700)
	else
		Duel.Destroy(c,REASON_COST)
	end
end
function s.ofil31(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL) and not c:IsDisabled()
end
function s.ofil32(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,id-10000)~=0 then
		return
	end
	--not fully implemented
	if Duel.IEMCard(s.ofil31,tp,"O","O",1,nil) then
		Duel.RegisterFlagEffect(tp,id-10000,RESET_PHASE+PHASE_END,0,1)
		local g=Duel.GMGroup(s.ofil32,tp,"O","O",nil)
		local tc=g:GetFirst()
		local tid=Duel.GetTurnCount()
		while tc do
			tc:RegisterFlagEffect(id-10000,RESET_EVENT+RESET_TOFIELD,0,0,tid)
			tc=g:GetNext()
		end
		local e1=MakeEff(c,"F","S")
		e1:SetCode(EFFECT_DISABLE)
		e1:SetTR("S","S")
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabel(tid)
		e1:SetTarget(s.otar31)
		c:RegisterEffect(e1)
		local e2=MakeEff(c,"FC","S")
		e2:SetCode(EFFECT_CHAIN_SOLVING)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetLabel(tid)
		e2:SetOperation(s.oop32)
		c:RegisterEffect(e2)
	end
end
function s.otar31(e,c)
	return c:IsType(TYPE_SPELL) and c:GetFlagEffectLabel(id-10000)==e:GetLabel()
end
function s.oop32(e,tp,eg,ep,ev,re,r,rp)
	local tloc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	local rc=re:GetHandler()
	if tloc&LOCATION_SZONE~=0 and re:IsActiveType(TYPE_SPELL) and rc:GetFlagEffectLabel(id-10000)==e:GetLabel() then
		Duel.NegateEffect(ev)
	end
end
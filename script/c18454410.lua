--비밀로 가는 보물통로
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	e1:SetTR("M",0)
	e1:SetTarget(s.otar11)
	Duel.RegisterEffect(e1,tp)
end
function s.otar11(e,c)
	return c:IsAttackBelow(1000)
end
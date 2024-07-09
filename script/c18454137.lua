--¸£ºí¶û ¾Û¼Òºê
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STf")
	e2:SetCode(EVENT_MOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	WriteEff(e2,2,"NO")
	c:RegisterEffect(e2)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLoc("S")
end
function s.ofil2(c)
	return c:IsFaceup() and c:IsSetCard("¸£ºí¶û") and c:IsAttackAbove(1)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=c:GetOwner()
	local g=Duel.GMGroup(s.ofil2,op,0,"M",nil)
	local sum=g:GetSum(Card.GetAttack)
	if sum<=0 then
		return
	end
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	e1:SetValue(sum)
	e1:SetTR("M",0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,"¸£ºí¶û"))
	Duel.RegisterEffect(e1,op)
end
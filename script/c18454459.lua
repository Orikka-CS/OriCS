--sparkle.exe: Click the sound and let it be
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","G")
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTR("S",0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabel(0)
	e1:SetCondition(s.ocon11)
	e1:SetTarget(s.otar11)
	e1:SetValue(s.oval11)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	Duel.RegisterEffect(e2,tp)
	e1:SetLabelObject(e2)
	e2:SetLabelObject(e1)
end
function s.ocon11(e)
	return e:GetLabel()==0
end
function s.otar11(e,c)
	return c:IsSetCard("sparkle.exe")
end
function s.oval11(e)
	local te=e:GetLabelObject()
	e:SetLabel(1)
	te:SetLabel(1)
end
function s.cfil2(c)
	return c:IsSetCard("sparkle.exe") and c:IsAbleToGraveAsCost() and c:IsType(TYPE_MONSTER) and c:GetAttack()>=1
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemoveAsCost() and Duel.IEMCard(s.cfil2,tp,"D",0,1,nil)
	end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.cfil2,tp,"D",0,1,1,nil)
	local tc=g:GetFirst()
	e:SetLabel(tc:GetAttack())
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tfil2(c)
	return c:IsSetCard("sparkle.exe") and c:IsSSetable() and not c:IsCode(id)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil2,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_DAMAGE,nli,0,tp,e:GetLabel())
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SMCard(tp,s.tfil2,tp,"D",0,1,1,nil)
	if #g>0 and Duel.SSet(tp,g)>0 then
		Duel.Damage(tp,e:GetLabel(),REASON_EFFECT)
	end
end
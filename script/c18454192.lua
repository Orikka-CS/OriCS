--푸른 눈의 얼티메이툰 드래곤
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,53183600,3)
	local e1=MakeEff(c,"S")
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"SC")
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	WriteEff(e2,2,"O")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"S")
	e3:SetCode(EFFECT_ATTACK_COST)
	e3:SetCost(s.cost3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"S")
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(s.con4)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"S")
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetCondition(s.con5)
	e5:SetValue(s.val5)
	c:RegisterEffect(e5)
	local e6=MakeEff(c,"S")
	e6:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e6:SetCondition(s.con5)
	c:RegisterEffect(e6)
	local e7=MakeEff(c,"FC","M")
	e7:SetCode(EVENT_LEAVE_FIELD)
	e7:SetCondition(s.con7)
	e7:SetOperation(s.op7)
	c:RegisterEffect(e7)
end
s.material_setcode={SET_BLUE_EYES,0x62}
s.listed_names={53183600,15259703}
function s.vfil1(c)
	return c:IsCode(15259703) and c:IsFaceup()
end
function s.val1(e,se,sp,st)
	local tp=e:GetHandlerPlayer()
	return (st&SUMMON_TYPE_FUSION)~=SUMMON_TYPE_FUSION or Duel.IEMCard(s.vfil1,tp,"O",0,1,nil)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function s.cost3(e,c,tp)
	return Duel.CheckLPCost(tp,500)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsAttackCostPaid()~=2 and c:IsLoc("M") then
		Duel.PayLPCost(tp,500)
		Duel.AttackCostPaid()
	end
end

function s.nfil4(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
function s.con4(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IEMCard(s.nfil4,tp,0,"M",1,nil)
end
function s.con5(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IEMCard(s.nfil4,tp,0,"M",1,nil)
end
function s.val5(e,c)
	return not c:IsType(TYPE_TOON) or c:IsFacedown()
end
function s.nfil7(c)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousCodeOnField()==15259703
		and c:IsPreviousLocation(LSTN("O"))
end
function s.con7(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.nfil7,1,nil)
end
function s.op7(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Destroy(c,REASON_EFFECT)
end
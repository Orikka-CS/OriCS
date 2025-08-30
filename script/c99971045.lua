--[ Heishou Pack ]
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_ATTACK,0)
	e1:SetRange(LOCATION_HAND)
	e1:SetValue(s.hspval)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_CONFIRM)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.con3)
	e3:SetTarget(s.tar3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
	
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(function(_,_,_,_,_,re) return re and re:GetHandler():IsCode(99971041) end)
	e4:SetTarget(s.tar3)
	e4:SetOperation(s.op3)
	c:RegisterEffect(e4)
	
end

function s.hspval(e,c)
	local tp=c:GetControler()
	local zone=ZONES_MMZ
	local lg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	for tc in aux.Next(lg) do
		zone=zone&(~tc:GetColumnZone(LOCATION_MZONE,0,0,tp))
	end
	return 0,zone
end

function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk ==0 then	return bc and bc:IsFaceup() and bc:IsRelateToBattle() and bc:GetAttack()<bc:GetDefense() and bc:IsAbleToRemove(tp,POS_FACEDOWN) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsFaceup() and bc:IsRelateToBattle() and bc:GetAttack()<bc:GetDefense() then
		Duel.Remove(bc,POS_FACEDOWN,REASON_EFFECT)
	end
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	e:SetLabelObject(tc)
	return tc and c:GetAttack()>=500 and c:GetDefense()>=500 and tc:IsFaceup() and (tc:GetAttack()>0 or tc:GetDefense()>0)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end

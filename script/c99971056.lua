--[ Heishou Pack ]
local s,id=GetID()
function s.initial_effect(c)
	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTarget(function(e,c) return e:GetHandler():GetColumnGroup():IsContains(c) end)
	c:RegisterEffect(e1)

	local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_FIELD)
	e12:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e12:SetRange(LOCATION_MZONE)
	e12:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e12:SetTargetRange(0,1)
	e12:SetCondition(s.dcon1)
	e12:SetValue(DOUBLE_DAMAGE)
	c:RegisterEffect(e12)
	
	local e14=Effect.CreateEffect(c)
	e14:SetType(EFFECT_TYPE_FIELD)
	e14:SetCode(EFFECT_SET_ATTACK_FINAL)
	e14:SetRange(LOCATION_MZONE)
	e14:SetProperty(EFFECT_FLAG_DELAY)
	e14:SetTargetRange(0,LOCATION_MZONE)
	e14:SetTarget(s.atktg)
	e14:SetValue(s.atkval)
	c:RegisterEffect(e14)
	local e15=e14:Clone()
	e15:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e15:SetValue(s.defval)
	c:RegisterEffect(e15)
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetCondition(s.con2)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	
	local e21=Effect.CreateEffect(c)
	e21:SetType(EFFECT_TYPE_SINGLE)
	e21:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e21)
	
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.con3)
	e3:SetTarget(s.tar3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(function(_,_,_,_,_,re) return re and re:GetHandler():IsCode(99971041) end)
	e4:SetTarget(s.tar3)
	e4:SetOperation(s.op3)
	c:RegisterEffect(e4)
	
end

function s.dcon1(e)
	local g=e:GetHandler():GetColumnGroup()
	local a,d=Duel.GetAttacker(),Duel.GetAttackTarget()
	return a:GetControler()==e:GetHandlerPlayer() and d and g:IsContains(d)
end

function s.atktg(e,c)
	local g=e:GetHandler():GetColumnGroup()
	return g:IsContains(c)
end
function s.atkval(e,c)
	return math.ceil(c:GetAttack()/2)
end
function s.defval(e,c)
	return math.ceil(c:GetDefense()/2)
end

function s.con2(e)
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL then return false end
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return d and a==c and d:IsDefensePos()
end
function s.val2(e,c)
	return c:GetBaseAttack()*2
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and Duel.IsBattlePhase()
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local seq=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	if seq then
		Duel.MoveSequence(c,math.log(seq,2))
	end
end

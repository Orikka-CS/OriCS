--[ Ven©ªmicTail ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(s.cbtg)
	e1:SetOperation(s.cbop)
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	
end

function s.cbtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.GetAttacker():IsHasEffect(EFFECT_CANNOT_DIRECT_ATTACK) end
end
function s.cbop(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	local c=e:GetHandler()
	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(100)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	at:RegisterEffect(e1)
	
	if at:CanAttack() and not at:IsStatus(STATUS_ATTACK_CANCELED) then
		Duel.ChangeAttackTarget(nil)
	end
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetOperation(function() if at:IsRelateToBattle() then Duel.Destroy(at,REASON_EFFECT) end end)
	e2:SetReset(RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e2,tp)
	
end

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x6d71)
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT|REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

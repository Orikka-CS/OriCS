--파이널 히어로 식스 플라워
function c17290001.initial_effect(c)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetValue(c17290001.val4)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DISABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetCondition(c17290001.con5)
	e5:SetTarget(c17290001.tg5)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EVENT_BATTLE_START)
	e7:SetCountLimit(1,17290001)
	e7:SetTarget(c17290001.tg7)
	e7:SetOperation(c17290001.op7)
	c:RegisterEffect(e7)
end
c17290001.listed_series={0x8}
function c17290001.mat_filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsSetCard(0x8)
end
function c17290001.val4(e,te)
	return te:IsActiveType(TYPE_MONSTER) and e:GetHandler()~=te:GetOwner()
end
function c17290001.con5(e)
	local c=e:GetHandler()
	return c:IsRelateToBattle()
end
function c17290001.tg5(e,c)
	return c:IsRelateToBattle() and c~=e:GetHandler()
end
function c17290001.tg7(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then
		return bc and bc:IsDestructable()
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
function c17290001.op7(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() then
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
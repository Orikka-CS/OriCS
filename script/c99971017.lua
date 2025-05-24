--[ JunkHunter ]
local s,id=GetID()
function s.initial_effect(c)

	aux.AddUnionProcedure(c,s.unfilter)
	
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(1000)
	c:RegisterEffect(e3)
	
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.damcon)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
	
end

function s.unfilter(c)
	return c:IsCode(60800381)
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=eg:GetFirst()
	local c=e:GetHandler()
	local eqc=c:GetEquipTarget()
	return eqc and eqc:IsReasonCard(bc) and bc:IsLocation(LOCATION_GRAVE) and bc:IsMonster()
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=eg:GetFirst()
	bc:CreateEffectRelation(e)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetAttack())
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local bc=eg:GetFirst()
	if bc:IsRelateToEffect(e) then
		local atk=bc:GetAttack()
		if atk<=0 then return end
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		Duel.Damage(p,atk,REASON_EFFECT)
	end
end

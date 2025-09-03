--인스펙터 프라임
local s,id=GetID()
function s.initial_effect(c)
	--order summon
	aux.AddOrderProcedure(c,"R",nil,aux.NOT(aux.FilterBoolFunctionEx(Card.IsType,TYPE_TOKEN)),aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT))
	c:EnableReviveLimit()
	--그 상대 몬스터의 공격력 / 수비력을 절반으로 한다.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--이 턴에 이 카드가 전투로 파괴한 몬스터의 수만큼 자신은 덱에서 드로우한다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE|PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(aux.bdcon)
	e3:SetOperation(s.bdop)
	c:RegisterEffect(e3)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsFaceup() and bc:IsRelateToBattle() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(bc:GetAttack()/2)
		bc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		e2:SetValue(bc:GetDefense()/2)
		bc:RegisterEffect(e2)
	end
	if c:IsRelateToEffect(e) and c:CanChainAttack() and c==Duel.GetAttacker() then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_DAMAGE_STEP_END)
		e3:SetOperation(s.caop)
		e3:SetCountLimit(1)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
		c:RegisterEffect(e3)
	end
end
function s.caop(e,tp)
	local c=e:GetHandler()
	if c:CanChainAttack() then
		Duel.ChainAttack()
	end
end
function s.bdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffectLabel(id) then
		c:SetFlagEffectLabel(id,c:GetFlagEffectLabel(id)+1)
	else
		c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1,1)
	end
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffectLabel(id)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetFlagEffectLabel(id)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp,chk)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
--커스펙터 프라임
local s,id=GetID()
function s.initial_effect(c)
	--order summon
	aux.AddOrderProcedure(c,"L",nil,aux.FilterBoolFunctionEx(Card.IsAttackAbove,2000),aux.FilterBoolFunctionEx(Card.IsSummonType,SUMMON_TYPE_SPECIAL),aux.FilterBoolFunctionEx(Card.IsType,TYPE_MONSTER))
	c:EnableReviveLimit()
	--그 카드를 파괴한다. 그 후, 상대에게 1000 데미지를 준다.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--그 몬스터의 공격력은, 그 파괴된 몬스터 중 1장의 원래 공격력만큼 올린다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
function s.atkconfilter(c,tp)
	return c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:GetBaseAttack()>0
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.atkconfilter,1,nil,tp)
end
function s.atkfilter(c)
	return c:IsFaceup() and (c:IsCustomType(CUSTOMTYPE_ORDER) or c:IsType(TYPE_ORDER))
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	if chk==0 then return eg:IsExists(s.atkconfilter,1,nil,tp) and Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local mg=eg:Filter(s.atkconfilter,nil,tp)
	mg:KeepAlive()
	e:SetLabelObject(mg)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsFaceup() and tc:IsRelateToEffect(e)) then return end
	local g=e:GetLabelObject()
	if #g>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		g=g:Select(tp,1,1,nil)
	end
	--Duel.HintSelection(g)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(g:GetFirst():GetBaseAttack())
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e1)
end
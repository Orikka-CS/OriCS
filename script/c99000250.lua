--고스펙터 프라임
local s,id=GetID()
function s.initial_effect(c)
	--order summon
	aux.AddOrderProcedure(c,"R",nil,s.ordfil1,aux.FilterBoolFunctionEx(Card.IsSummonLocation,LOCATION_EXTRA),aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT))
	c:EnableReviveLimit()
	--자신은 묘지로 보낸 몬스터의 공격력만큼 LP를 상실한다.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--그 몬스터를 패에 넣는다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--이 카드의 공격력은 턴 종료시까지, 자신 묘지의 몬스터의 속성의 종류 × 500 올린다.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetCountLimit(1)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.regcon)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
end
function s.ordfil1(c)
	return (c:IsCustomType(CUSTOMTYPE_ORDER) or c:IsType(TYPE_ORDER))
end
function s.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	Duel.SendtoGrave(tc,REASON_COST)
	e:SetLabel(tc:GetAttack())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(tp,Duel.GetLP(tp)-e:GetLabel())
end
function s.cfilter2(c,tp)
	return c:IsType(TYPE_EFFECT) and c:IsAbleToGraveAsCost() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_HAND|LOCATION_MZONE,0,2,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_HAND|LOCATION_MZONE,0,2,2,e:GetHandler(),tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0 and aux.StatChangeDamageStepCondition()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)>0 end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)
	local val=g:GetClassCount(Card.GetCode)*500
	if c:IsFaceup() and c:IsRelateToEffect(e) and val>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		c:RegisterEffect(e1)
	end
end
function s.rfilter(c,tp)
	return c:IsControler(tp) and c:IsMonster() and not c:IsReason(REASON_RETURN)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rfilter,1,nil,tp)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
end
--저 바람에 맞서서 날아올라
local s,id=GetID()
function s.initial_effect(c)
	--이 카드의 발동은 패에서도 할 수 있으며,
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE)
	e0a:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0a:SetCondition(s.actcon)
	c:RegisterEffect(e0a)
	--세트한 턴에도 발동할 수 있다.
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_SINGLE)
	e0b:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0b:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0b:SetCondition(s.actcon)
	c:RegisterEffect(e0b)
	--	
	local e0=Effect.CreateEffect(c)	
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PREDRAW)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e0:SetRange(0xf7)
	e0:SetOperation(s.op)
	c:RegisterEffect(e0)
	--덱에서 함정 카드 1장을 패에 넣는다.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.actcon(e)
	return Duel.GetTurnCount()~=1
end
function s.op(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),0xf7,0,2,nil,id) then
		Duel.Win(1-tp,0x0)
	end
end
function s.confilter(c)
	if not (c:IsMonsterCard() and c:IsFaceup()) then return false end
	local effs={c:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:IsHasType(EFFECT_TYPE_QUICK_O|EFFECT_TYPE_QUICK_F) and eff:GetCode()==EVENT_CHAINING then
			return true
		end
	end
	return false
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) end
	return Duel.IsExistingMatchingCard(s.confilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,nil)
end
function s.filter(c)
	return c:IsTrap() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.HasFlagEffect(tp,id) then return end
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	--이 턴에 1번만, 자신은 함정 카드를 패에서 발동할 수 있다.
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
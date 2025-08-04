--시네크로워커 린
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsAttribute,ATTRIBUTE_DARK),1,99,s.exmatfilter)
	c:EnableReviveLimit()
	--그 몬스터와 이 카드를 뒷면 수비 표시로 한다.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--상대의 엑스트라 덱을 확인하고, 그 중의 1장을 뒷면으로 제외한다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.necro_con)
	e2:SetTarget(s.necro_tg)
	e2:SetOperation(s.necro_op)
	c:RegisterEffect(e2)
	--뒷면 표시의 이 몬스터를 대상으로 하는 마법 / 함정 / 몬스터의 효과가 발동했을 때, 이 카드를 앞면 수비 표시로 하고 발동할 수도 있다.
	local e2a=e2:Clone()
	e2a:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2a:SetCondition(s.con)
	e2a:SetCost(Cost.SelfChangePosition(POS_FACEUP_DEFENSE))
	c:RegisterEffect(e2a)
	--이 턴에, 상대는 패를 버리고 발동하는 효과 및 패를 묘지로 보내고 발동하는 효과를 발동할 수 없다.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetOperation(s.actop)
	c:RegisterEffect(e3)
end
function s.exmatfilter(c,scard,sumtype,tp)
	return c:IsRace(RACE_ZOMBIE,scard,sumtype,tp)
end
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsSummonPlayer(1-tp) and (not e or c:IsRelateToEffect(e))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.filter,1,nil,nil,tp) end
	Duel.SetTargetCard(eg)
	eg:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,#eg,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local g=Group.FromCards(c,tc)
	if g:IsExists(function(c,e) return not c:IsFaceup() or not c:IsRelateToEffect(e) end,1,nil,e) then return end
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	g:Match(Card.IsControler,nil,1-tp)
	for tc in g:Match(Card.IsPosition,nil,POS_FACEDOWN_DEFENSE):Iter() do
		--Cannot change its battle position
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3313)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.necro_con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsContains(c)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and c:IsFacedown()) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsContains(c)
end
function s.necro_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil,tp,POS_FACEDOWN) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end
function s.necro_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	Duel.ConfirmCards(tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil,tp,POS_FACEDOWN)
	if Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		c:ReleaseEffectRelation(re)
	end
	Duel.ShuffleExtra(1-tp)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_DISCARD_HAND)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TO_GRAVE_AS_COST)
	e2:SetTargetRange(0,LOCATION_HAND)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
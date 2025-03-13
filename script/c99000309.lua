--깨져버린 고대의 맹약
local s,id=GetID()
function s.initial_effect(c)
	--이 카드는 발동 후, 필드에 계속해서 남고,
	local ea=Effect.CreateEffect(c)
	ea:SetType(EFFECT_TYPE_ACTIVATE)
	ea:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(ea)
	local eb=Effect.CreateEffect(c)
	eb:SetType(EFFECT_TYPE_SINGLE)
	eb:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(eb)
	--상대 필드에 "맹약 토큰" 1장을 특수 소환하는 것에 의해 상대 필드에 발동할 수도 있다.
	local ec=Effect.CreateEffect(c)
	ec:SetType(EFFECT_TYPE_FIELD)
	ec:SetCode(EFFECT_ACTIVATE_COST)
	ec:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET)
	ec:SetTargetRange(1,1)
	ec:SetTarget(s.meiyakutg)
	ec:SetOperation(s.meiyakuop)
	Duel.RegisterEffect(ec,0)
	--상대의 패 및 상대 필드에 세트된 카드를 전부 확인한다.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetCondition(function(e,tp) return e:GetHandler():GetOwner()==tp end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--이 카드가 마법 카드의 효과를 발동하기 위해 제외되었을 경우에 발동할 수 있다.
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.bncon)
	e2:SetOperation(s.bnop)
	c:RegisterEffect(e2)
end
s.listed_series={0xc16}
s.listed_names={99000295}
function s.meiyakutg(e,te,tp)
	local c=e:GetHandler()
	local tc=te:GetHandler()
	return c==tc and not tc:IsLocation(LOCATION_SZONE) and te:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.meiyakuop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,99000296,0,TYPES_TOKEN,1000,1000,1,RACE_WARRIOR,ATTRIBUTE_LIGHT,POS_FACEUP,1-tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local token=Duel.CreateToken(tp,99000296)
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
		Duel.MoveToField(c,tp,1-tp,LOCATION_FZONE,POS_FACEUP,false)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,67)
	else
		return true
	end
end
function s.cfilter(c,tp)
	return (c:IsNormalSpell() or c:IsHasEffect(99000305,tp)) and c:IsAbleToRemoveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local nc=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
	if chk==0 then 
		if Duel.IsPlayerAffectedByEffect(tp,99000407) then return true else return nc end
	end
	if nc and not (Duel.IsPlayerAffectedByEffect(tp,99000407) and Duel.SelectYesNo(tp,aux.Stringid(99000407,0))) then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.filter(c,g,tp)
	return not (g:IsContains(c) or c==mc) and c:GetColumnGroup():IsExists(Card.IsControler,1,nil,1-tp)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g1=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local g2=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	g1:Merge(g2)
	Duel.ConfirmCards(tp,g1)
	local tc=g1:GetFirst()
	local check=0
	while tc do
		if Duel.IsExistingMatchingCard(Card.IsCode,tp,0,LOCATION_GRAVE,1,nil,tc:GetCode()) then
			check=check+1
		end
		tc=g1:GetNext()
	end
	local cg=c:GetColumnGroup()
	local dg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c,cg,tp)
	if check>0 and #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local sg=dg:Select(tp,1,1,nil):GetFirst()
		Duel.HintSelection(sg,true)
		local g=sg:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
	Duel.ShuffleHand(1-tp)
end
function s.bncon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return c:IsReason(REASON_COST) and rc:IsType(TYPE_SPELL)
end
function s.bnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--이 턴 중에, 자신 필드의 "맹약" 몬스터는 전투 / 효과로는 파괴되지 않는다.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xc16))
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,3))
end
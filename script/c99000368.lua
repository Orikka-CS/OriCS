--MEIYAKU@SPELL
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
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetCondition(function(e,tp) return e:GetHandler():GetOwner()==tp end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e1a)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
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
s.listed_series={0xc16,0xc13}
s.listed_names={99000295}
function s.meiyakutg(e,te,tp)
	local c=e:GetHandler()
	local tc=te:GetHandler()
	return c==tc and not tc:IsLocation(LOCATION_SZONE) and te:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.meiyakuop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,99000371,0,TYPES_TOKEN,1000,1000,1,RACE_WARRIOR,ATTRIBUTE_LIGHT,POS_FACEUP,1-tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local token=Duel.CreateToken(tp,99000371)
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
function s.filter(c,tp,g)
	return c:IsSummonPlayer(tp) and c:IsAbleToDeck() and c:IsLocation(LOCATION_MZONE) and g:IsContains(c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=e:GetHandler():GetColumnGroup()
	if chk==0 then return eg:IsExists(s.filter,1,nil,1-tp,cg) end
	local g=eg:Filter(s.filter,nil,1-tp,cg)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(Card.IsRelateToEffect,nil,e)
	if #g==0 then return end
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	local seq=0
	local og=Duel.GetOperatedGroup()
	local tc=og:GetFirst()
	for tc in aux.Next(og) do
		seq=bit.replace(seq,0x1,tc:GetPreviousSequence())
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetLabel(seq*0x10000)
	e1:SetOperation(s.disop)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end
function s.disop(e,tp)
	return e:GetLabel()
end
function s.bncon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return c:IsReason(REASON_COST) and rc:IsType(TYPE_SPELL)
end
function s.bnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--자신의 "맹약" 카드 및 "@SPELL" 마법 카드의 효과 발동 및 그 발동한 효과는 무효화되지 않는다.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_INACTIVATE)
	e1:SetValue(s.chainfilter)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_DISEFFECT)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DISABLE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(s.distarget)
	Duel.RegisterEffect(e3,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,2))
end
function s.distarget(e,c)
	return c:IsSetCard(0xc13) or c:IsSetCard(0xc16)
end
function s.chainfilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and (te:GetHandler():IsSetCard(0xc13) or te:GetHandler():IsSetCard(0xc16))
end
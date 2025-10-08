--윤회의 인조천사
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
	--그 발동을 무효로 하고, 그 카드를 덱으로 되돌린다.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--이 카드의 발동 후, 이 카드가 묘지로 보내졌을 때에 적용한다.
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2a:SetCode(EVENT_LEAVE_FIELD_P)
	e2a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2a:SetOperation(function(e) e:SetLabel(e:GetHandler():IsStatus(STATUS_LEAVE_CONFIRMED) and 1 or 0) end)
	c:RegisterEffect(e2a)
	--이 듀얼 중, 자신의 "인조천사"는 이하의 효과를 얻는다.
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2b:SetCode(EVENT_TO_GRAVE)
	e2b:SetCondition(function(e) return e:GetLabelObject():GetLabel()==1 end)
	e2b:SetOperation(s.retop)
	e2b:SetLabelObject(e2a)
	c:RegisterEffect(e2b)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_NEGATED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={16946849}
s.listed_series={0xc12}
function s.Synthetic_Seraphim_Filter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsRace(RACE_FAIRY)
end
function s.actcon(e)
	return Duel.IsExistingMatchingCard(s.Synthetic_Seraphim_Filter,e:GetHandlerPlayer(),0,LOCATION_MZONE|LOCATION_GRAVE,1,nil)
end
function s.cfilter(c)
	return c:IsFaceup() and (c:IsCode(16946849) or c:IsCode(16946850) or c:IsSetCard(0xc12))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsMonsterEffect() or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1400) end
	Duel.PayLPCost(tp,1400)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsAbleToDeck() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
	end
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	and ((c:IsLocation(LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
	or (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	if Duel.NegateActivation(ev) and ec:IsRelateToEffect(re) then
		ec:CancelToGrave()
		if Duel.SendtoDeck(ec,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and ec:IsLocation(LOCATION_DECK|LOCATION_EXTRA) then
			local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,nil,e,tp)
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=g:Select(tp,1,1,nil)
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,id)>0 then return end
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_NEGATED)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.damcon1)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_NEGATED)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_NEGATED)
	local e4=e1:Clone()
	e4:SetCode(EVENT_CHAIN_NEGATED)
	e4:SetCondition(s.damcon2)
	local ea=Effect.CreateEffect(c)
	ea:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	ea:SetTargetRange(0xff,0)
	ea:SetTarget(s.eftg)
	ea:SetLabelObject(e1)
	Duel.RegisterEffect(ea,tp)
	local eb=Effect.CreateEffect(c)
	eb:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	eb:SetTargetRange(0xff,0)
	eb:SetTarget(s.eftg)
	eb:SetLabelObject(e2)
	Duel.RegisterEffect(eb,tp)
	local ec=Effect.CreateEffect(c)
	ec:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	ec:SetTargetRange(0xff,0)
	ec:SetTarget(s.eftg)
	ec:SetLabelObject(e3)
	Duel.RegisterEffect(ec,tp)
	local ed=Effect.CreateEffect(c)
	ed:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	ed:SetTargetRange(0xff,0)
	ed:SetTarget(s.eftg)
	ed:SetLabelObject(e4)
	Duel.RegisterEffect(ed,tp)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
	if de then
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,dp,0,0)
	end
end
function s.damcon1(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp
end
function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
	local dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_PLAYER)
	return dp==tp and (re:IsMonsterEffect() or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1400)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1400)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.eftg(e,c)
	if c:IsCode(16946849) and c:GetFlagEffect(id)==0 then
		c:RegisterFlagEffect(id,0,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
	end
	return c:IsCode(16946849)
end
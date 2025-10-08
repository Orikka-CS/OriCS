--인조천사는 천사를 꿈꾸는가
local s,id=GetID()
function s.initial_effect(c)
	--이 카드의 발동은 상대 턴에 패에서도 할 수 있으며,
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE)
	e0a:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	c:RegisterEffect(e0a)
	--세트한 턴에도 발동할 수 있다.
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_SINGLE)
	e0b:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
	e0b:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	c:RegisterEffect(e0b)
	--이하의 효과를 각각 적용할 수 있다.
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1a:SetType(EFFECT_TYPE_ACTIVATE)
	e1a:SetCode(EVENT_FREE_CHAIN)
	e1a:SetCountLimit(1,id)
	e1a:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1a:SetCost(s.cost)
	e1a:SetTarget(s.target)
	e1a:SetOperation(s.operation)
	c:RegisterEffect(e1a)
	--이 효과의 발동은 카운터 함정 카드의 발동으로도 취급한다.
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD)
	e1b:SetCode(EFFECT_ACTIVATE_COST)
	e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET)
	e1b:SetTargetRange(1,1)
	e1b:SetTarget(function(e,te,tp) return te==e:GetLabelObject() end)
	e1b:SetOperation(
	function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if Duel.IsExistingMatchingCard(s.Synthetic_Seraphim_Filter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_TYPE)
			e1:SetValue(TYPE_TRAP+TYPE_COUNTER)
			e1:SetReset(RESET_CHAIN)
			c:RegisterEffect(e1,true)
		end
	end)
	e1b:SetLabelObject(e1a)
	Duel.RegisterEffect(e1b,0)
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
end
s.listed_names={16946849}
s.listed_series={0xc12}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetSpellSpeed(3)
	e:SetType(EFFECT_TYPE_ACTIVATE)
	e:SetLabel(1)
	return true
end
function s.plfilter(c,tp)
	return c:IsCode(16946849) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.thfilter(c,tp)
	return (c:IsCode(16946849) or c:IsCode(16946850) or c:IsSetCard(0xc12)) and c:IsMonster() and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,c)
end
function s.tgfilter(c)
	return c:IsCounterTrap() and c:IsAbleToGrave()
end
function s.Synthetic_Seraphim_Filter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsRace(RACE_FAIRY)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,tp)
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return b1 or b2
	end
	e:SetLabel(0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,tp)
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp)
	local breakeffect=false
	if (b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(id,1)))) then
		--자신의 패 / 덱 / 묘지 / 제외 상태인 "인조천사" 1장을 자신의 마법 & 함정 존에 앞면 표시로 놓는다.
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
		if tc then 
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp)
		end
		breakeffect=true
	end
	if (b2 and (not breakeffect or Duel.SelectYesNo(tp,aux.Stringid(id,2)))) then
		--덱에서 "인조천사" 몬스터 1장을 패에 넣고, 덱에서 카운터 함정 카드 1장을 묘지로 보낸다.
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local hg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
		if #hg>0 and Duel.SendtoHand(hg,tp,REASON_EFFECT)>0 and hg:GetFirst():IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,hg)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,id)>0 then return end
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	--자신 필드의 마법 / 함정 카드는 효과의 대상이 되지 않으며
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSpellTrap))
	e1:SetValue(1)
	--효과로는 파괴되지 않는다.
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetValue(1)
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
end
function s.eftg(e,c)
	if c:IsCode(16946849) and c:GetFlagEffect(id)==0 then
		c:RegisterFlagEffect(id,0,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
	end
	return c:IsCode(16946849)
end
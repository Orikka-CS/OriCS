--인조천사강림
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
	--자신의 덱 / 묘지에서 "인조천사" 몬스터를 2장까지 수비 표시로 특수 소환한다.
	local e1a=Effect.CreateEffect(c)
	e1a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1a:SetType(EFFECT_TYPE_ACTIVATE)
	e1a:SetCode(EVENT_FREE_CHAIN)
	e1a:SetCountLimit(1,id)
	e1a:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1a:SetCost(s.spcost)
	e1a:SetTarget(s.sptg)
	e1a:SetOperation(s.spop)
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
	if not s.global_check then
		s.global_check=true
		s[0]=0
		s[1]=0
		s[2]=0
		s[3]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PAY_LPCOST)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_TURN_END)
		ge2:SetOperation(s.clear)
		Duel.RegisterEffect(ge2,0)
	end
end
s.listed_names={16946849}
s.listed_series={0xc12}
function s.actfil(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.actcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0
		or Duel.IsExistingMatchingCard(s.actfil,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetSpellSpeed(3)
	e:SetType(EFFECT_TYPE_ACTIVATE)
	e:SetLabel(1)
	return true
end
function s.spfilter(c,e,tp)
	return (c:IsCode(16946849) or c:IsCode(16946850) or c:IsSetCard(0xc12)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.Synthetic_Seraphim_Filter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsRace(RACE_FAIRY)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	ft=math.min(ft,2)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,ft,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,id)>0 then return end
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	--자신 / 상대의 스탠바이 페이즈에 발동한다. 자신은 직전의 턴 중에 지불한 LP의 합계만큼만 회복한다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetTarget(s.rectg)
	e2:SetOperation(s.recop)
	local eb=Effect.CreateEffect(c)
	eb:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	eb:SetTargetRange(0xff,0)
	eb:SetTarget(s.eftg)
	eb:SetLabelObject(e2)
	Duel.RegisterEffect(eb,tp)
end
function s.eftg(e,c)
	if c:IsCode(16946849) and c:GetFlagEffect(id)==0 then
		c:RegisterFlagEffect(id,0,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
	return c:IsCode(16946849)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local val=math.ceil(ev)
	s[ep]=s[ep]+val
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
	s[0+2]=s[0]
	s[0]=0
	s[1+2]=s[1]
	s[1]=0
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	local val=s[tp+2]
	if chk==0 then return val>0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(val)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end
--무녀 미코
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon condition
	local ea=Effect.CreateEffect(c)
	ea:SetType(EFFECT_TYPE_SINGLE)
	ea:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	ea:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(ea)
	--special summon rule
	local eb=Effect.CreateEffect(c)
	eb:SetType(EFFECT_TYPE_FIELD)
	eb:SetCode(EFFECT_SPSUMMON_PROC)
	eb:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	eb:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	eb:SetRange(LOCATION_EXTRA)
	eb:SetCondition(s.sprcon)
	eb:SetTarget(s.sprtg)
	eb:SetOperation(s.sprop)
	c:RegisterEffect(eb)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--miko miko
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.mikocon)
	e2:SetOperation(s.mikoop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
function s.chainfilter(re,tp,cid)
	return not (re:IsActiveType(TYPE_MONSTER) and Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)==LOCATION_HAND)
end
function s.sprfilter(c,tp,sc)
	return c:IsAbleToDeckAsCost() and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return (Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)~=0 or Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)~=0)
		and Duel.IsExistingMatchingCard(s.sprfilter,tp,LOCATION_HAND,0,1,nil,tp,c)
end
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_HAND,0,nil,tp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=Group.Select(g,tp,1,1,Duel.IsSummonCancelable())
	if not tc then return false end
	tc:KeepAlive()
	e:SetLabelObject(tc)
	return true
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonLocation()==LOCATION_EXTRA
end
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAttack(500) and c:IsDefense(300) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,3,3,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
		local tg=sg:Select(1-tp,1,1,nil)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	end
end
function s.cfilter(c,p)
	return c:IsControler(p)
end
function s.mikocon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
function s.mikoop(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))+1
	local reset,reset_ct=0,0
	local reset2,reset_ct2=0,0
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()<=PHASE_STANDBY then
		reset,reset_ct=RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2
	else
		reset=RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN
	end
	if Duel.GetCurrentPhase()<=PHASE_STANDBY then
		reset2,reset_ct2=RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN,2
	else
		reset2=RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN
	end
	if opt==1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		e1:SetTargetRange(0,0xff)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetTarget(s.rmtg)
		e1:SetReset(reset,reset_ct)
		Duel.RegisterEffect(e1,tp)
		local eff1=Effect.CreateEffect(e:GetHandler())
		eff1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		eff1:SetTargetRange(0,1)
		eff1:SetDescription(aux.Stringid(id,2))
		eff1:SetReset(reset,reset_ct)
		Duel.RegisterEffect(eff1,tp)
		if tp~=Duel.GetTurnPlayer() then
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
			e2:SetTargetRange(0xff,0)
			e2:SetValue(LOCATION_REMOVED)
			e2:SetTarget(s.rmtg2)
			e2:SetReset(reset2,reset_ct2)
			Duel.RegisterEffect(e2,tp)
			local eff2=Effect.CreateEffect(e:GetHandler())
			eff2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			eff2:SetTargetRange(1,0)
			eff2:SetDescription(aux.Stringid(id,2))
			eff2:SetReset(reset2,reset_ct2)
			Duel.RegisterEffect(eff2,tp)
		end
	elseif opt==2 then
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_REMOVE)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetTargetRange(0,1)
		e3:SetValue(1)
		e3:SetReset(reset,reset_ct)
		Duel.RegisterEffect(e3,tp)
		local eff3=Effect.CreateEffect(e:GetHandler())
		eff3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		eff3:SetTargetRange(0,1)
		eff3:SetDescription(aux.Stringid(id,3))
		eff3:SetReset(reset,reset_ct)
		Duel.RegisterEffect(eff3,tp)
		--30459350 chk
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(30459350)
		e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e4:SetTargetRange(0,1)
		e4:SetReset(reset,reset_ct)
		Duel.RegisterEffect(e4,tp)
		if tp~=Duel.GetTurnPlayer() then
			local e5=Effect.CreateEffect(e:GetHandler())
			e5:SetType(EFFECT_TYPE_FIELD)
			e5:SetCode(EFFECT_CANNOT_REMOVE)
			e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e5:SetTargetRange(1,0)
			e5:SetValue(1)
			e5:SetReset(reset2,reset_ct2)
			Duel.RegisterEffect(e5,tp)
			local eff5=Effect.CreateEffect(e:GetHandler())
			eff5:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			eff5:SetTargetRange(1,0)
			eff5:SetDescription(aux.Stringid(id,3))
			eff5:SetReset(reset2,reset_ct2)
			Duel.RegisterEffect(eff5,tp)
			--30459350 chk
			local e6=Effect.CreateEffect(e:GetHandler())
			e6:SetType(EFFECT_TYPE_FIELD)
			e6:SetCode(30459350)
			e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e6:SetTargetRange(1,0)
			e6:SetReset(reset2,reset_ct2)
			Duel.RegisterEffect(e6,tp)
		end
	end
end
function s.rmtg(e,c)
	return c:GetOwner()~=e:GetHandlerPlayer() and Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),c)
end
function s.rmtg2(e,c)
	local tp=e:GetHandlerPlayer()
	return c:GetOwner()==tp and Duel.IsPlayerCanRemove(tp,c)
end
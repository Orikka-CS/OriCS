--렉스퀴아트 생츄어리
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,0)
	e2:SetTarget(s.tg2)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2a:SetCode(EVENT_CHAINING)
	e2a:SetRange(LOCATION_SZONE)
	e2a:SetOperation(s.op2a)
	c:RegisterEffect(e2a)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(1,0)
	e3:SetTarget(function(e,c) return c:IsSetCard(0xf30) and c:IsLocation(LOCATION_GRAVE) end)
	c:RegisterEffect(e3)
end

--effect 1
function s.tg1filter(c)
	return c:IsSetCard(0xf30) and c:IsType(TYPE_FUSION) and c:IsAbleToDeck()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_GRAVE,0,nil)
	local b1=#g>0
	local b2=e:GetHandler():IsNegatable()
	if chk==0 then return true end
	if not (b1 or b2) then return end 
	local b=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	e:SetLabel(b)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b=e:GetLabel()
	if b==1 then
		local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_GRAVE,0,nil)
		if #g==0 then return end
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	else
		c:NegateEffects(c,RESET_PHASE+PHASE_END,true)
	end
end


--effect 2
function s.tg2(e,c)
	return c:IsFaceup() and c:IsSetCard(0xf30) and c:IsType(TYPE_FUSION)
end

function s.op2a(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsType(TYPE_FUSION) and rc:IsSetCard(0xf30) and rc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and re:IsActiveType(TYPE_MONSTER) and re:GetOwnerPlayer()==tp then
		Duel.SetChainLimit(function(e,ep,tp) return ep==tp or not e:IsActiveType(TYPE_SPELL+TYPE_TRAP) end)
	end
end
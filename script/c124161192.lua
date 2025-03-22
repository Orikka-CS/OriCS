--페더록스 파라
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf2c) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.tg3)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end

--effect 1
function s.val1filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()==0
end

function s.val1(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.val1filter,tp,LOCATION_MZONE,0,nil)
	local x=0
	if #g==0 then return 0 end
	for tc in aux.Next(g) do
		x=x+tc.minxyzct
	end
	return x*200
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,tp)
end

function s.tg2filter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e)
end

function s.tg2xfilter(c)
	return c:IsSetCard(0xf2c) and not c:IsType(TYPE_FIELD)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,0,nil,e)
	local xg=Duel.GetMatchingGroup(s.tg2xfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if chk==0 then return #g>0 and #xg>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetFirstTarget()
	local xg=Duel.GetMatchingGroup(s.tg2xfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if tg:IsRelateToEffect(e) and #xg>0 then 
		local xsg=aux.SelectUnselectGroup(xg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_XMATERIAL)
		Duel.Overlay(tg,xsg,true)
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetOperation(s.op2op)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		tg:RegisterEffect(e1)
	end
end

function s.op2op(e,tp,eg,ep,ev,re,r,rp)
	local og=e:GetHandler():GetOverlayGroup()
	if #og>0 then 
		Duel.SendtoGrave(og,REASON_EFFECT)
	end
end

--effect 3
function s.tg3(e,c)
	return c:IsSetCard(0xf2c) and c:GetOverlayCount()==0
end
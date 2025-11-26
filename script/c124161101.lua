--독훼귀투기명
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
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf26) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(function(e) return Duel.GetFieldGroup(e:GetHandlerPlayer(),0,LOCATION_MZONE)>Duel.GetFieldGroup(e:GetHandlerPlayer(),LOCATION_MZONE,0) end)
	e3:SetTarget(s.tg3)
	e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e3)
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD)
	e3a:SetCode(EFFECT_CHANGE_DAMAGE)
	e3a:SetRange(LOCATION_FZONE)
	e3a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3a:SetCondition(function(e) return Duel.GetFieldGroup(e:GetHandlerPlayer(),0,LOCATION_MZONE)>Duel.GetFieldGroup(e:GetHandlerPlayer(),LOCATION_MZONE,0) end)
	e3a:SetTargetRange(0,1)
	e3a:SetValue(s.val3)
	c:RegisterEffect(e3a)
end

--effect 1
function s.val1(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_XYZ)
	local x=0
	local ct=0
	if #g==0 then return 0 end
	for tc in aux.Next(g) do
		ct=tc:GetOverlayCount()
		if ct>x then
			x=ct
		end
	end
	return x*100
end

--effect 2
function s.tg2ffilter(c)
	return c:IsSetCard(0xf26)
end

function s.tg2filter(c,e)
	return c:IsType(TYPE_XYZ) and c:GetOverlayGroup():FilterCount(s.tg2ffilter,nil)>0 and c:IsFaceup() and c:IsCanBeEffectTarget(e)
end

function s.tg2xfilter(c,e)
	return c:IsSetCard(0xf26) and not c:IsType(TYPE_FIELD)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,0,nil,e)
	local xg=Duel.GetMatchingGroup(s.tg2xfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 and #xg>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local xg=Duel.GetMatchingGroup(s.tg2xfilter,tp,LOCATION_DECK,0,nil)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg and Duel.Damage(1-tp,tg:GetOverlayGroup():FilterCount(s.tg2ffilter,nil)*300,REASON_EFFECT)>0 and #xg>0 then
		local xsg=aux.SelectUnselectGroup(xg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_XMATERIAL)
		Duel.Overlay(tg,xsg,true)
	end
end

--effect 3
function s.tg3filter(c)
	return c:IsSetCard(0xf26)
end

function s.tg3(e,c)
	return c:IsType(TYPE_XYZ) and c:GetOverlayGroup():FilterCount(s.tg3filter,nil)>0
end

function s.val3(e,re,val,r,rp)
	if r&REASON_EFFECT==REASON_EFFECT and re and re:IsActiveType(TYPE_MONSTER) then
		local rc=re:GetHandler()
		if rc:IsFaceup() and rc:IsType(TYPE_XYZ) and rc:GetOverlayGroup():FilterCount(s.tg3filter,nil)>0 then
			return val*2
		end
	end
	return val
end
--페더록스 필드
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
	e1:SetTarget(function(_,c) return c:IsSetCard(0xf2c) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e2:SetCountLimit(1,id)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.con2)
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
function s.con2filter(c)
	return c:IsSetCard(0xf2c) and not c:IsType(TYPE_FIELD) and c:IsAbleToRemoveAsCost()
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local g=Duel.GetMatchingGroup(s.con2filter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	return #g>0 and (r&REASON_COST)~=0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ) and rc:GetOverlayCount()==0 and ep==e:GetOwnerPlayer() and ev>=1 and rc:GetOverlayCount()>=ev-1
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.con2filter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end

--effect 3
function s.tg3(e,c)
	return c:IsSetCard(0xf2c) and c:GetOverlayCount()==0
end
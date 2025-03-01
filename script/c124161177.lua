--백연초가 피어오르는 숲
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
	e1:SetTarget(function(_,c) return c:IsSetCard(0xf2b) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_LPCOST_REPLACE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
end

--effect 1
function s.val1(e,c)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),124161179)*300
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if re and tp==ep and rc:IsSetCard(0xf2b) and not rc:IsType(TYPE_FIELD) and Duel.GetFlagEffect(e:GetHandlerPlayer(),id)==0 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT,0,0)
		local res=Duel.CheckLPCost(1-ep,ev//2)
		e:GetHandler():ResetFlagEffect(id)
		return res
	end
	return false
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT,0,0)
	Duel.PayLPCost(1-ep,ev//2)
	c:ResetFlagEffect(id)
end

--effect 3
function s.val3(e,re,tp)
	local tp=e:GetHandlerPlayer()
	local lp=math.min(Duel.GetLP(tp),Duel.GetLP(1-tp))
	return re:GetHandler():IsAttackAbove(lp) and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsLocation(LOCATION_HAND)
end
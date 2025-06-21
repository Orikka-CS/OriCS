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
	e1:SetLabelObject(e1)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf2b) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1b:SetCode(EVENT_PAY_LPCOST)
	e1b:SetRange(LOCATION_FZONE)
	e1b:SetLabelObject(e1)
	e1b:SetOperation(s.regop)
	c:RegisterEffect(e1b)
	local e1c=e1b:Clone()
	e1c:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1c:SetCode(EVENT_LEAVE_FIELD_P)
	e1c:SetOperation(function(e) e:GetLabelObject():SetLabel(0) end)
	c:RegisterEffect(e1c)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con2)
	e2:SetCost(Cost.PayLP(100))
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.con3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
	--count
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PAY_LPCOST)
		ge1:SetOperation(s.cnt)
		Duel.RegisterEffect(ge1,0)
	end)
end

--count
function s.cnt(e,tp,eg,ep,ev,re,r,rp)
	if re and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then
		re:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
	end
end

--effect 1
function s.val1(e,c)
	return e:GetLabelObject():GetLabel()*100
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then
		local val=e:GetLabelObject():GetLabel()
		e:GetLabelObject():SetLabel(val+1)
	end
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsSetCard(0xf2b) and rc~=e:GetHandler() and rp==tp
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.op2filter(e,c)
	return c:IsSetCard(0xf2b) and c:IsFaceup() and not c:IsType(TYPE_FIELD)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTarget(s.op2filter)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetValue(aux.tgoval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

--effect 3
function s.con3filter(c)
	return c:IsSetCard(0xf2b)
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con3filter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	return g>0
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:HasFlagEffect(id) and re:GetOwnerPlayer()==tp then
		Duel.SetChainLimit(function(e,ep,tp) return ep==tp end)
	end
end
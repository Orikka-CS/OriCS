--페더록스 라이
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_GRAVE,0)
	e2:SetTarget(function(e,c) return c:IsSetCard(0xf2c) end)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end


--effect 1
function s.con1filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf2c) and c:IsType(TYPE_XYZ)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_MZONE,0,nil)>0 and rp==1-tp and Duel.IsChainNegatable(ev)
end

function s.tg1filter(c,tp)
	return c:IsAbleToRemove(1-tp) and c:IsFaceup()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(s.tg1filter,tp,LOCATION_MZONE,0,nil,tp) end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.op1op)
end

function s.op1op(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_MZONE,nil,1-tp)
	if #rg>0 then
		local rsg=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE):GetFirst()
		if Duel.Remove(rsg,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)>0 and rsg:IsLocation(LOCATION_REMOVED) and not rsg:IsReason(REASON_REDIRECT) then
			Duel.BreakEffect()
			Duel.ReturnToField(rsg)
		end
	end
end
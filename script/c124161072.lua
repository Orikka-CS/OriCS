--Tempetrix Shambles
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
	e1:SetTarget(function(_,c) return c:IsSetCard(0xf24) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--effect 2
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.con2)
	e3:SetCost(s.cst2)
	e3:SetTarget(s.tg2)
	e3:SetOperation(s.op2)
	c:RegisterEffect(e3)
	--effect 3
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(s.con3)
	e4:SetOperation(s.op3)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EVENT_CHAIN_END)
	e5:SetOperation(s.op3a)
	c:RegisterEffect(e5)  
	--count
	aux.GlobalCheck(s,function()
		local cnt=Effect.CreateEffect(c)
		cnt:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		cnt:SetCode(EVENT_DESTROYED)
		cnt:SetOperation(s.cnt)
		Duel.RegisterEffect(cnt,0)
	end)
end

--count
function s.cnt(e,tp,eg,ep,ev,re,r,rp)
	for tc in eg:Iter() do
		if tc:IsReason(REASON_EFFECT) then Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1) end
	end
end

--effect 1
function s.val1(e)
	return Duel.GetFlagEffect(e:GetHandler():GetControler(),id)*200
end

--effect 2
function s.con2filter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetPreviousControler()==1-tp
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.con2filter,1,nil,tp)
end

function s.cst2filter(c)
	local te=c:GetActivateEffect()
	return ((c:IsSetCard(0xf24) and not c:IsType(TYPE_FIELD)) or (c:IsSpell() and te:IsHasCategory(CATEGORY_DESTROY))) and not c:IsPublic()
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_HAND,0,nil,e,tp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONFIRM)
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(tp)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	Duel.Destroy(sg,REASON_EFFECT)
end

--effect 3
function s.con3filter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.con3filter,1,nil,tp)
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain()==0 then
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
	end
end

function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	e:Reset()
end

function s.op3a(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id)>0 then
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	e:GetHandler():ResetFlagEffect(id)
end

function s.chainlm(e,rp,tp)
	return tp==rp
end
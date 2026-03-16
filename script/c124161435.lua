--트라비니카 에지스 하이프
local s,id=GetID()
function s.initial_effect(c)
	--fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf3c),aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER))
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.con1)
	e1:SetCost(Cost.SelfRelease)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE_FIELD)
	e2:SetProperty(EFFECT_FLAG_REPEAT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--count
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetCondition(s.cntcon)
		ge1:SetOperation(s.cntop1)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_CHAIN_NEGATED)
		ge2:SetCondition(s.cntcon)
		ge2:SetOperation(s.cntop2)
		Duel.RegisterEffect(ge2,0)
	end)
end

--count
function s.cntcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsOnField()
end

function s.cntop1(e,tp,eg,ep,ev,re,r,rp)
	re:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
end

function s.cntop2(e,tp,eg,ep,ev,re,r,rp)
	local ct=re:GetHandler():GetFlagEffect(id)
	re:GetHandler():ResetFlagEffect(id)
	for i=1,ct-1 do
		re:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end

--effect 1
function s.con1filter(c,tp)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_HAND)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and r&REASON_EFFECT~=0 and eg:FilterCount(s.con1filter,nil,tp)>0
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.con1filter,nil,tp):Filter(Card.IsAbleToDeck,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.con1filter,nil,tp):Filter(Card.IsAbleToDeck,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

--effect 2
function s.op2filter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup() and c:GetFlagEffect(id)==0
end

function s.op2(e,tp)
	local zone=0
	local g=Duel.GetMatchingGroup(s.op2filter,tp,LOCATION_MZONE,0,nil)
	for tc in g:Iter() do
		local seq=tc:GetSequence()
		local op_seq
		if seq<=4 then op_seq=4-seq
		elseif seq==5 then op_seq=3
		elseif seq==6 then op_seq=1
		end
		if op_seq then
			zone=zone|(1<<(16+8+op_seq))
		end
	end
	return zone
end
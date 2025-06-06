--클라랑슈의 낙원지기 에덴
local s,id=GetID()
function s.initial_effect(c)
	--link
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,2,nil,s.linkfilter)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(function(e,c) return c:HasFlagEffect(id) end)
	e2:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
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

--link
function s.matfilter(c,scard,sumtype,tp)
	return not c:IsType(TYPE_EFFECT,scard,sumtype,tp) 
end

function s.linkfilter(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0xf2d,lc,sumtype,tp)
end

--effect 1
function s.tg1cfilter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler() and not c:HasFlagEffect(id)
end

function s.tg1filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf2d)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=Duel.GetMatchingGroup(s.tg1cfilter,tp,0,LOCATION_MZONE,nil)
	local g=Duel.GetMatchingGroupCount(s.tg1filter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return #cg>0 and g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,cg,1,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local cg=Duel.GetMatchingGroup(s.tg1cfilter,tp,0,LOCATION_MZONE,nil)
	local g=Duel.GetMatchingGroupCount(s.tg1filter,tp,LOCATION_ONFIELD,0,nil)
	local z=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if #cg>0 and g>0 and z>0 then
		local ct=math.min(g,z)
		csg=aux.SelectUnselectGroup(cg,e,tp,1,ct,aux.TRUE,1,tp,HINTMSG_CONTROL)
		Duel.GetControl(csg,tp)
	end
end

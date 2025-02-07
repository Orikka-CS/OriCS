--클라랑슈의 낙원지기 에덴
local s,id=GetID()
function s.initial_effect(c)
	--link
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf2d),2,nil,s.linkfilter)
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
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.cnt)
		Duel.RegisterEffect(ge1,0)
	end) 
end

--count
function s.cnt(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if re:IsMonsterEffect() and rc:IsRelateToEffect(re) and loc==LOCATION_MZONE then
		rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end

--link
function s.ffilter(c,lc,sumtype,tp)
	return not c:IsType(TYPE_EFFECT,lc,sumtype,tp)
end

function s.linkfilter(g,lc,sumtype,tp)
	return g:IsExists(s.ffilter,1,nil,lc,sumtype,tp)
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

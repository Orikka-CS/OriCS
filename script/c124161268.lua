--오메가히트 셀리스티 안젤리카
local s,id=GetID()
function s.initial_effect(c)
	--link
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,nil,s.linkfilter)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.tg2)
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	local e2a=e2:Clone()
	e2a:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2a:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2a:SetValue(aux.tgoval)
	c:RegisterEffect(e2a)
	--count
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DRAW)
		ge1:SetOperation(s.cnt)
		Duel.RegisterEffect(ge1,0)
	end)
end

--count
function s.cnt(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFlagEffect(ep,id)
	if Duel.GetTurnCount()==0 then return end
	if ev>ct then
		for i=1,ev-ct do
			Duel.RegisterFlagEffect(ep,id,0,0,1)
		end
	end
end

--link
function s.linkfilter(g,lnkc,sumtype,sp)
	return g:IsExists(Card.IsSetCard,1,nil,0xf31,lnkc,sumtype,sp)
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsSetCard(0xf31) and rp==tp
end

function s.cst1filter(c)
	return c:IsSetCard(0xf31) and c:IsAbleToRemoveAsCost()
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetFlagEffect(tp,id)*2
	if chk==0 then return ct>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFlagEffect(tp,id)
	local ac=ct*2
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ac then
		Duel.DisableShuffleCheck()
		local g=Duel.GetDecktopGroup(tp,ac)
		Duel.ConfirmCards(tp,g)
		Duel.SortDecktop(tp,tp,ac)
	end
end

--effect 2
function s.tg2(e,c)
	return c:IsFaceup() and c:IsSetCard(0xf31)
end
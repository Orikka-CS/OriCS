--Astaterea Astrum
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
	e1:SetTarget(function(_,c) return c:IsSetCard(0xf25) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--effect 2
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.cst2)
	e3:SetTarget(s.tg2)
	e3:SetOperation(s.op2)
	c:RegisterEffect(e3)
	--effect 3
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(0,1)
	e4:SetValue(s.val3)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_SSET)
	e5:SetRange(LOCATION_FZONE)
	e5:SetOperation(s.op3)
	c:RegisterEffect(e5)
end

--effect 1
function s.val1(e,c)
	local tp=e:GetHandlerPlayer()
	local ug=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)-1
	local dg=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if ug>dg then
		dg=ug
	end
	return dg*200
end

--effect 2
function s.cst2filter(c)
	return c:IsSetCard(0xf25) and not c:IsType(TYPE_FIELD) and c:IsAbleToRemoveAsCost()
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	local ug=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	local dg=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 and ug~=dg end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local ug=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	local dg=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	local sg
	if #ug+#dg>0 and #ug~=#dg then
		if #dg>#ug and #ug>0 then
			sg=aux.SelectUnselectGroup(ug,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DESTROY)
		end
		if #ug>#dg and #dg>0 then
			sg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DESTROY)
		end
		Duel.Destroy(sg,REASON_EFFECT)
	end
end

--effect 3
function s.val3(e,re,tp)
	local c=re:GetHandler()
	return c:GetFlagEffect(id)>0
end

function s.op3filter(c)
	return c:IsSetCard(0xf25) and c:IsType(TYPE_LINK) and c:IsFaceup()
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local g=Duel.GetMatchingGroup(s.op3filter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	for tc in aux.Next(eg) do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
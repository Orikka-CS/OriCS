--란샤르드 아바리스
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.con2)
	e2:SetTargetRange(0,1)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
end

--effect 1
function s.cst1filter(c)
	return c:IsSetCard(0xf2e) and c:IsAbleToRemoveAsCost()
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end

function s.tg1filter(c)
	return c:IsSetCard(0xf2e) and c:IsMonster()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_HAND,0,nil)
	local og=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_HAND,nil)
	if chk==0 then return #g>0 and #og>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_HAND)
end

function s.op1filter(c,tp)
	return c:GetOwner()==1-tp 
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_HAND,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg,1-tp,REASON_EFFECT)
		local og=Duel.GetMatchingGroup(s.op1filter,tp,0,LOCATION_HAND,nil,tp)
		if #og==0 then return end
		Duel.BreakEffect()
		local osg=aux.SelectUnselectGroup(og,e,tp,1,1,aux.TRUE,1,1-tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(osg,tp,REASON_EFFECT)
	end 
end

--effect 2
function s.con2filter(c)
	return c:IsSetCard(0xf2e) and c:IsType(TYPE_FUSION) and c:IsFaceup()
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroupCount(s.con2filter,tp,LOCATION_MZONE,0,nil)
	return g>0
end

function s.val2(e,re,tp)
	local rc=re:GetHandler()
	return re:GetActivateLocation()==LOCATION_GRAVE and rc:IsMonster() and rc:IsPreviousLocation(LOCATION_HAND)
end
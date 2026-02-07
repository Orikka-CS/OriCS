--뮬베이릿 크베르크
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
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf3a) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.con3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end

--effect 1
function s.val1filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end

function s.val1(e,c)
	return Duel.GetMatchingGroupCount(s.val1filter,e:GetHandlerPlayer(),LOCATION_REMOVED,LOCATION_REMOVED,nil)*100
end

--effect 2
function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end

function s.tg2filter(c)
	return c:IsSetCard(0xf3a) and c:IsFaceup() and not c:IsType(TYPE_FIELD)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.tg2filter,tp,LOCATION_REMOVED,0,nil)
	local g1=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local g2=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	local max=math.min(ct,g1,g2)
	if chk==0 then return max>0 end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,LOCATION_DECK)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.tg2filter,tp,LOCATION_REMOVED,0,nil)
	local g1=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local g2=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	local max=math.min(ct,g1,g2)
	if max>0 then
		local ac=Duel.AnnounceNumberRange(tp,1,max)
		local sg1=Duel.GetDecktopGroup(tp,ac)
		local sg2=Duel.GetDecktopGroup(1-tp,ac)
		sg1:Merge(sg2)
		Duel.DisableShuffleCheck()
		Duel.SendtoGrave(sg1,REASON_EFFECT)
	end
end
--effect 3
function s.con3filter(c)
	return c:IsSetCard(0xf3a) and c:IsFaceup() and c:IsType(TYPE_MONSTER)
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(s.con3filter,tp,LOCATION_REMOVED,0,nil)>0 and rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.GetMatchingGroupCount(Card.IsCode,tp,0,LOCATION_REMOVED,nil,re:GetHandler():GetCode())>0 
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
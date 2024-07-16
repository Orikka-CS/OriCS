--Astaterea Lady Virgo
local s,id=GetID()
function s.initial_effect(c)
	--link
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,4,s.linkfilter)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--link
function s.linkfilter(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0xf25,lc,sumtype,tp)
end

--effect 1
function s.cst1filter(c)
	return c:IsSetCard(0xf25) and c:IsAbleToDeckOrExtraAsCost() and c:IsFaceup()
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ug=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	local dg=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil) 
	local diff=math.abs(ug-dg)
	local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if chk==0 then return #g>=diff end
	local sg=aux.SelectUnselectGroup(g,e,tp,diff,diff,aux.TRUE,1,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ug=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	local dg=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil) 
	local diff=math.abs(ug-dg)
	if chk==0 then return diff>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,diff,0,LOCATION_ONFIELD)
	if ug>dg then
		Duel.SetChainLimit(s.chlimitu)
	end
	if dg>ug then
		Duel.SetChainLimit(s.chlimitd)
	end
end

function s.chlimitu(e,ep,tp)
	local c=e:GetHandler()
	return tp==ep or not c:IsLocation(LOCATION_ONFIELD) or (c:IsFacedown() and c:IsLocation(LOCATION_ONFIELD)) 
end

function s.chlimitd(e,ep,tp)
	local c=e:GetHandler()
	return tp==ep or not c:IsLocation(LOCATION_ONFIELD) or (c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD)) 
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local ug=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	local dg=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil) 
	local sg
	local diff=math.abs(#ug-#dg)
	if diff==0 then return end
		if #ug>#dg then
			sg=aux.SelectUnselectGroup(ug,e,tp,diff,diff,aux.TRUE,1,tp,HINTMSG_TODECK)
		end
		if #dg>#ug then
			sg=aux.SelectUnselectGroup(dg,e,tp,diff,diff,aux.TRUE,1,tp,HINTMSG_TODECK)
		end
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	local ug=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	local dg=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	return ug==dg and rp~=tp
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
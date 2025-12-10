--메가히트 디바 원더플람
local s,id=GetID()
function s.initial_effect(c)
	--link
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_LINK),2,nil,s.linkfilter)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY+CATEGORY_NEGATE)
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
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
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
	return re:GetHandler()~=e:GetHandler()
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local cl=Duel.GetCurrentChain()
	if chk==0 then return Duel.CheckLPCost(tp,cl*100) end
	Duel.PayLPCost(tp,cl*100)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD+LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_NEGATE,nil,1,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetCurrentChain()
	if Duel.IsPlayerCanDraw(tp) then
		local dt=Duel.AnnounceNumberRange(tp,1,ct)
		Duel.Draw(tp,dt,REASON_EFFECT)
		Duel.BreakEffect()
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
		local dsg=aux.SelectUnselectGroup(dg,e,tp,dt,dt,aux.TRUE,1,tp,HINTMSG_DESTROY)
		Duel.Destroy(dsg,REASON_EFFECT)
		local et=Duel.GetOperatedGroup():FilterCount(Card.IsSetCard,nil,0xf31)
		local ch=Duel.GetCurrentChain()-1
		local trig_p,trig_e=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
		if et>0 and ch>0 and trig_p==1-tp and Duel.IsChainNegatable(ch) then
			Duel.BreakEffect()
			Duel.NegateActivation(ch)
			if trig_e:GetHandler():IsRelateToEffect(trig_e) then
				Duel.Destroy(trig_e:GetHandler(),REASON_EFFECT)
			end
		end
	end
end

--effect 2
function s.con2filter(c)
	return c:IsReason(REASON_EFFECT)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.con2filter,1,nil)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	local ct=Duel.GetFlagEffect(tp,id)
	if chk==0 then return #g>0 and ct>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	local ct=Duel.GetFlagEffect(tp,id)
	if #g>0 and ct>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.TRUE,1,tp,HINTMSG_RTOHAND)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
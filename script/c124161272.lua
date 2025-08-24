--메가히트 크레이즈
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)   
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():IsReason(REASON_EFFECT) end)
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

--effect 1
function s.tg1filter(c,e)
	return c:IsNegatable() and c:IsCanBeEffectTarget(e) and c:IsFaceup()
end

function s.tg1dfilter(c)
	return c:IsSetCard(0xf31) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and s.tg1filter(chkc,e) end
	local ct=Duel.GetFlagEffect(tp,id)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_ONFIELD,nil,e)
	local dg=Duel.GetMatchingGroup(s.tg1dfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler())
	if chk==0 then return #g>0 and ct>0 and #dg>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.TRUE,1,tp,HINTMSG_NEGATE)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,sg,#sg,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dg=Duel.GetMatchingGroup(s.tg1dfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler())
	local tg=Duel.GetTargetCards(e)
	if #dg>0 then
		local dsg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DESTROY)
		if Duel.Destroy(dsg,REASON_EFFECT)>0 and #tg>0 then
			for tc in aux.Next(tg) do
				tc:NegateEffects(c,RESET_PHASE+PHASE_END,true)
			end
		end
	end
end

--effect 2
function s.tg2filter(c)
	return c:IsSetCard(0xf31) and not c:IsPublic()
end

function s.tg2dfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_HAND,0,nil)
	local dg=Duel.GetMatchingGroup(s.tg2dfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 and #dg>0 end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,dg,1,1-tp,LOCATION_MZONE)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_HAND,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONFIRM)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleHand(tp)
		local dg=Duel.GetMatchingGroup(s.tg2dfilter,tp,0,LOCATION_MZONE,nil)
		if #dg>0 then
			local dsg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_POSCHANGE)
			Duel.ChangePosition(dsg,POS_FACEDOWN_DEFENSE)
		end
	end
end
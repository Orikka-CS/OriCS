--뮬베이릿 큐비에
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e2a=e2:Clone()
	e2a:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2a)
end

--effect 1
function s.tg1filter(c)
	return c:IsSpellTrap() and c:IsSetCard(0xf3a) and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end

function s.op1filter(c)
	return c:IsAbleToGrave() and c:IsSetCard(0xf3a)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		local gg=Duel.GetMatchingGroup(s.op1filter,tp,LOCATION_HAND,0,nil)
		if #gg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local gsg=aux.SelectUnselectGroup(gg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DISCARD):GetFirst()
			Duel.SendtoGrave(gsg,REASON_EFFECT+REASON_DISCARD)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCountLimit(1,{id,2})
			e1:SetTargetRange(LOCATION_HAND,0)
			e1:SetTarget(function(e,c) return c:IsSetCard(0xf3a) end)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e1a=e1:Clone()
			e1a:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
			Duel.RegisterEffect(e1a,tp)
		end
	end
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_FUSION)
end

function s.tg2filter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsCanBeEffectTarget(e)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,0,LOCATION_MZONE,nil,e)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg and tg:IsFaceup() then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetOperation(s.op2op)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tg:RegisterEffect(e1)
	end
end

function s.op2op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:NegateEffects(c,nil,true)
end
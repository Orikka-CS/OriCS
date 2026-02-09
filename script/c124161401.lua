--뮬베이릿 필스티
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetCost(Cost.SelfBanish)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end

function s.tg1filter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsCanBeEffectTarget(e)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tg1filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_MZONE,nil,e)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg and tg:IsFaceup() then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_DRAW)
		e1:SetType(EFFECT_TYPE_QUICK_F)
		e1:SetCode(EVENT_CHAINING)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(s.op1con)
		e1:SetTarget(s.op1tg)
		e1:SetOperation(s.op1op)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tg:RegisterEffect(e1,true)
	end
end

function s.op1con(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(0xf3a) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end

function s.op1tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end

function s.op1op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(1-tp,1,REASON_EFFECT)
end

--effect 2
function s.con2filter(c,tp)
	return c:IsSetCard(0xf3a) and c:IsType(TYPE_FUSION) and c:IsControler(tp) and c:IsFaceup()
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,tp)>0
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		if Duel.IsPlayerCanDraw(tp,1) then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
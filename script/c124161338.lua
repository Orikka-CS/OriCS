--스노위퍼 아미스티스
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1dfilter(c)
	return c:IsSetCard(0xf35) and c:IsFaceup() and c:IsAbleToDeck()
end

function s.tg1filter(c,e)
	return c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end

function s.tg1ctfilter(c)
	return c:GetSequence()==0 or c:GetSequence()==4
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.tg1filter(chkc,e) end
	local c=e:GetHandler()
	local dg=Duel.GetMatchingGroup(s.tg1dfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil,e)
	if chk==0 then return #dg>0 and #g>0 end
	local ct=1
	if Duel.GetMatchingGroupCount(s.tg1ctfilter,tp,0,LOCATION_ONFIELD,nil)>0 then ct=2 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.TRUE,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	local g=Duel.GetMatchingGroup(s.tg1dfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if #tg>0 and #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttackTarget()
	return at and (at:GetSequence()==0 or at:GetSequence()==4) and at:IsControler(tp)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,LOCATION_DECK)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateAttack() and Duel.IsPlayerCanDraw(tp,1) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
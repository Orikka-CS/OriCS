--아스타테리아 에리투도
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SSET)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c,e,tp)
	return c:IsSetCard(0xf25) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tg1filter(chkc,e,tp) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tg then
		Duel.SpecialSummon(tg,0,tp,1-tp,false,false,POS_FACEUP_ATTACK|POS_FACEDOWN_DEFENSE)
		local g=Duel.GetMatchingGroup(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,nil)
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONTROL)
			Duel.GetControl(sg,tp)
		end
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsFacedown() and c:IsControler(1-tp)
end

function s.con2(e,tp,eg)
	return eg:IsExists(s.con2filter,1,nil,tp)
end

function s.tg2filter(c,e,tp)
	return c:IsFacedown() and c:IsControler(1-tp) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.tg2filter(chkc,e,tp) end
	local c=e:GetHandler()
	local g=eg:Filter(s.tg2filter,nil,e,tp)
	if chk==0 then return #g>0 and c:IsAbleToDeck() end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.op2filter(c)
	return c:IsSetCard(0xf25) and c:IsFaceup()
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg and c:IsRelateToEffect(e) then
		local dg=Group.FromCards(c,tg)
		Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		local ug=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
		local dg=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
		local ct=math.abs(ug-dg)
		if ct>0 and Duel.IsPlayerCanDiscardDeck(tp,ct) and Duel.GetMatchingGroupCount(s.op2filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,c)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.ShuffleDeck(tp)
			Duel.DisableShuffleCheck()
			Duel.DiscardDeck(tp,ct,REASON_EFFECT)
		end
	end
end
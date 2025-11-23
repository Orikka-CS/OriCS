--언엔달 엠버 피닉스
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1filter(c,e,tp,re,rp)
	return re and c:IsReason(REASON_COST) and re:IsActivated() and rp==tp and re:GetHandler():IsSetCard(0xf23) and c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con1filter,nil,e,tp,re,rp)>0
end

function s.tg1filter(c,e,tp,re,rp)
	return re and c:IsReason(REASON_COST) and re:IsActivated() and rp==tp and re:GetHandler():IsSetCard(0xf23) and c:IsControler(tp) and c:IsAbleToHand() and c:IsLocation(LOCATION_GRAVE) and c:IsCanBeEffectTarget(e)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tg1filter(chkc,e,tp,re,rp) end
	local g=eg:Filter(s.tg1filter,nil,e,tp,re,rp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,tp,LOCATION_GRAVE)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,124161059)>0
end

function s.tg2filter(c)
	return c:IsSetCard(0xf23) and c:IsFaceup() and c:IsAbleToDeck()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,c)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,c)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
		if Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
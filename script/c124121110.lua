--G.Rock 라인
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCountLimit(1)
	e3:SetCondition(s.con3)
	e3:SetTarget(s.tar3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCountLimit(1,{id,1})
	e4:SetCost(s.cost4)
	e4:SetTarget(s.tar4)
	e4:SetOperation(s.op4)
	c:RegisterEffect(e4)
end
function s.tfil21(c)
	return c:IsSetCard(0xfa6) and c:IsAbleToDeck() and c:IsFaceup()
end
function s.tfil22(c)
	return c:IsSetCard(0xfa6) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and s.tfil21(chkc)
			and chkc:IsControler(tp)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tfil21,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.tfil22,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.tfil21,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tfil22,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleDeck(tp)
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsType(TYPE_XYZ)
end
function s.tfil3(c)
	return c:IsSetCard(0xfa6) and c:IsXyzSummonable(nil)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil3,tp,LOCATION_EXTRA,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.tfil3,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.XyzSummon(tp,tc)
	end
end
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST)
	end
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return true
	end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then
		return
	end
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if fc then
		Duel.SendtoGrave(fc,REASON_RULE)
		Duel.BreakEffect()
	end
	Duel.MoveToField(c,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
end
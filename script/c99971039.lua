--[ Deadmoon ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCL(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	
end

function s.tar1f(c,tp)
	return c:IsCode(99971036) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,99971036),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		or Duel.IsEnvironment(99971036) then
		e:SetCategory(CATEGORY_DESTROY)
		if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,1-tp,0)
	else
		if chk==0 then return Duel.IsExistingMatchingCard(s.tar1f,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp) end
		Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,99971036),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		or Duel.IsEnvironment(99971036) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,2,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.SelectMatchingCard(tp,s.tar1f,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
		Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
	end
end

function s.tar2f(c)
	return c:IsSetCard(0x9d71) and c:IsM() and c:IsAbleToDeck()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tar2f(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToHand()
		and Duel.IsExistingTarget(s.tar2f,tp,LOCATION_GRAVE,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tar2f,tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK|LOCATION_EXTRA) then
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
			Duel.ShuffleDeck(tp)
		end
		if c:IsRelateToEffect(e) then
			Duel.BreakEffect()
			Duel.SendtoHand(c,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,c)
		end
	end
end

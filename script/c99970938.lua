--[ ReversedCloud ]
local s,id=GetID()
function s.initial_effect(c)

	local e9=Effect.CreateEffect(c)
	e9:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e9:SetType(EFFECT_TYPE_ACTIVATE)
	e9:SetCode(EVENT_FREE_CHAIN)
	e9:SetTarget(s.tar9)
	e9:SetOperation(s.op9)
	c:RegisterEffect(e9)
	
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
	
end

function s.tar9fil(c)
	return c:IsSetCard(0xcd6f) and c:IsMonster() and c:IsAbleToHand()
end
function s.tar9(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar9fil,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op9(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tar9fil,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.plfilter(c)
	local p=c:GetOwner()
	return c:IsSetCard(0xcd6f) and c:IsMonster() and Duel.GetLocationCount(p,LOCATION_SZONE)>0 and c:CheckUniqueOnField(p)
		and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.plfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.plfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.plfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
		tc:RegisterEffect(e1)
	end
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.SendtoDeck(e:GetHandler(),nil,1,REASON_EFFECT)
	end
end

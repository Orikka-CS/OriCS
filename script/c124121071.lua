--붉은 눈의 흉격
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end

function s.filter(c,ft,e,tp)
	return c:IsLevelBelow(7) and c:IsSetCard(0x3b) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,ft,e,tp) and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,e:GetHandler())
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND,0,nil)
	if #rg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local srg=rg:Select(tp,1,1,nil)
	Duel.SendtoDeck(srg,nil,1,REASON_EFFECT)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,0)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,ft,e,tp)
	if #g>0 then
		local th=g:GetFirst():IsAbleToHand()
		local sp=ft>0 and g:GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false)
		local op=0
		if th and sp then op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
		elseif th then op=0
		else op=1 end
		if op==0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		else
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.disfilter(c)
	return c:IsSetCard(SET_RED_EYES) and c:IsFaceup()
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==tp and rc:IsSetCard(SET_RED_EYES) and re:IsActiveType(TYPE_MONSTER)
end
function s.discostfilter(c)
	return c:IsSetCard(SET_RED_EYES) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemoveAsCost()
	end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsNegatableMonster() and chkc:IsLocation(LOCATION_MZONE)
	end
	if chk==0 then return Duel.IsExistingTarget(Card.IsNegatableMonster,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(s.discostfilter,tp,LOCATION_HAND|LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsNegatableMonster,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND|LOCATION_SZONE)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.discostfilter,tp,LOCATION_HAND|LOCATION_SZONE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.Destroy(g,REASON_EFFECT)>0 then
			local tc=Duel.GetFirstTarget()
			if tc:IsRelateToEffect(e) and tc:IsNegatableMonster() then
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				--Negate its effects
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESETS_STANDARD_PHASE_END)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESETS_STANDARD_PHASE_END)
				tc:RegisterEffect(e2)
				Duel.AdjustInstantly(tc)
				if tc:IsDisabled() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
					Duel.BreakEffect()
					Duel.Destroy(tc,REASON_EFFECT)
				end
			end
		end
	end
end

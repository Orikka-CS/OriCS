--Clavicula Xerdial
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE+CATEGORY_DRAW+CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
end

--effect 1
function s.tg1filter(c)
	return c:IsSetCard(0xf29) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.op1filter(c)
	return c:IsSetCard(0xf29) and c:IsMonster() and not c:IsPublic()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,sg)
	local cg=Duel.GetMatchingGroup(s.op1filter,tp,LOCATION_HAND,0,nil)
	if not (#cg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0))) then return end
	local csg=aux.SelectUnselectGroup(cg,e,tp,1,5,aux.dncheck,1,tp,HINTMSG_CONFIRM)
	Duel.ConfirmCards(1-tp,csg)
	Duel.ShuffleHand(tp)
	local ag
	local asg
	ag=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
	if #csg>0 and #ag>0 then
		Duel.BreakEffect()
		asg=aux.SelectUnselectGroup(ag,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE)
		Duel.Remove(asg,POS_FACEUP,REASON_EFFECT)
	end
	if #csg>1 and Duel.IsPlayerCanDraw(tp,1) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	ag=Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,nil,e,0,tp,false,false,POS_FACEUP)
	if #csg>2 and #ag>0 then
		Duel.BreakEffect()
		asg=aux.SelectUnselectGroup(ag,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
		Duel.SpecialSummon(asg,0,tp,tp,false,false,POS_FACEUP)
	end
	ag=Duel.GetMatchingGroup(Card.IsDiscardable,tp,0,LOCATION_HAND,nil,REASON_EFFECT)
	if #csg>3 and #ag>0 then
		Duel.BreakEffect()
		asg=ag:RandomSelect(tp,1)
		Duel.SendtoGrave(asg,REASON_EFFECT+REASON_DISCARD)
	end  
	if #csg>4 and c:IsSSetable(true) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.BreakEffect()
		c:CancelToGrave()
		Duel.ChangePosition(c,POS_FACEDOWN)
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
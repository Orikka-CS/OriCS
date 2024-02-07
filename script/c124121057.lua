--주술의 가면
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.afil1)
end
s.listed_names={124121056}
function s.afil1(c)
	return c:IsRace(RACE_FIEND)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	e:SetLabel(1)
	if chk==0 then
		return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.ctar11)
	Duel.RegisterEffect(e1,tp)
end
function s.ctar11(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_FIEND)
end
function s.cfil1(c,tp)
	local g=Duel.GetMatchingGroup(s.tfil1,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,c)
	return c:IsCode(124121056) and not c:IsPublic() and g:GetClassCount(Card.GetCode)>=2
end
function s.tfil1(c,ec)
	return not c:IsCode(id) and c:IsAbleToHand() and ec:ListsCode(c:GetCode())
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=1 then
			return false
		end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.cfil1,tp,LOCATION_EXTRA,0,1,nil,tp)
			and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,c)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfil1,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabelObject(g:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,c)
	if #dg<1 or Duel.SendtoDeck(dg,nil,2,REASON_EFFECT)==0 then
		return
	end
	Duel.ShuffleDeck(tp)
	Duel.BreakEffect()
	local ec=e:GetLabelObject()
	local g=Duel.GetMatchingGroup(s.tfil1,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,ec)
	if aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,0) then
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_ATOHAND,nil,nil,true)
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
function s.tfil21(c,tp)
	return c:IsAbleToDeck() and Duel.GetMZoneCount(tp,c)>0
end
function s.tfil22(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttack(1500)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil21,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.tfil22,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local dg=Duel.SelectMatchingCard(tp,s.tfil21,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp)
	if #dg<1 or Duel.SendtoDeck(dg,nil,2,REASON_EFFECT)==0
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		return
	end
	Duel.ShuffleDeck(tp)
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.tfil22,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--[ ChaoticWing ]
local s,id=GetID()
function s.initial_effect(c)

	local e99=MakeEff(c,"F","MG")
	e99:SetCode(id)
	e99:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e99:SetTargetRange(1,0)
	c:RegisterEffect(e99)
	
	local e0=MakeEff(c,"FTo","G")
	e0:SetD(id,0)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_LEAVE_FIELD)
	e0:SetCL(1,{id,1})
	WriteEff(e0,0,"NTO")
	c:RegisterEffect(e0)

	local e1=MakeEff(c,"I","H")
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCL(1,id)
	e1:SetCost(aux.SelfDiscardCost)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
end

s.listed_names={CARD_CYCLONE}

function s.con0fil(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT)
end
function s.con0(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsSpellEffect() and re:GetHandler():IsOriginalType(TYPE_SPELL)
		and eg:IsExists(s.con0fil,1,nil)
end
function s.tar0(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_EITHER,LOCATION_ONFIELD)
end
function s.op0(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=g:Select(tp,1,1,nil)
			Duel.HintSelection(dg,true)
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end

function s.tar1fil(c)
	return c:IsCode(CARD_CYCLONE) and c:IsAbleToHand() and (c:IsLocation(LSTN("DG")) or c:IsFaceup())
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar1fil,tp,LSTN("DGR"),0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tar1fil),tp,LSTN("DGR"),0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

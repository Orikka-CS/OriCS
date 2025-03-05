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
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_LEAVE_FIELD)
	e0:SetCL(1,{id,1})
	WriteEff(e0,0,"NTO")
	c:RegisterEffect(e0)

	local e1=MakeEff(c,"I","H")
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DICE)
	e1:SetCL(1,id)
	e1:SetCost(aux.SelfRevealCost)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
end

s.listed_names={CARD_CYCLONE_DICE}

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
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_EITHER,LOCATION_MZONE)
end
function s.op0(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			local hg=g:Select(tp,1,1,nil)
			Duel.HintSelection(hg,true)
			Duel.BreakEffect()
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
		end
	end
end

function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.op0fil(c)
	return c:IsCode(CARD_CYCLONE_DICE) and c:IsAbleToHand() and (c:IsLocation(LSTN("DG")) or c:IsFaceup())
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dc=Duel.TossDice(tp,1)
	if dc==1 or dc==6 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc=Duel.SelectMatchingCard(tp,s.op0fil,tp,LSTN("DGR"),0,1,1,nil):GetFirst()
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	elseif dc==5 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		Duel.Destroy(g,REASON_EFFECT)
	else
		if c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

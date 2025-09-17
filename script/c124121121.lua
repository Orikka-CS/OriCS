--요화의 식
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
s.listed_series={0xfa7}
function s.tfil1(c)
	return c:IsSetCard(0xfa7) and c:IsMonster() and c:IsAbleToHand()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil1,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.ofil1(c,tc)
	return c:IsAbleToGrave() and c:ListsCode(tc:GetCode()) and not c:IsOriginalCode(tc:GetOriginalCode())
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tfil1,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,tc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=Duel.SelectMatchingCard(tp,s.ofil1,tp,LOCATION_DECK+LOCATION_EXTRA,0,0,1,nil,tc)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
function s.nfil2(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsMonster() and c:IsSetCard(0xfa7)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.nfil2,1,nil,tp)
end
function s.tfil21(c,e,tp,ec)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.tfil22,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,Group.FromCards(c,ec))
end
function s.tfil22(c)
	return c:IsSetCard(0xfa7) and c:IsAbleToDeck() and c:IsFaceup()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return eg:IsExists(s.tfil21,1,nil,e,tp,c) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsAbleToDeck()
	end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,3,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.ofil2(c,e,tp,ec)
	return c:IsRelateToEffect(e) and s.tfil21(c,e,tp,ec)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=eg:FilterSelect(tp,s.ofil2,1,1,nil,e,tp,c)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0
		and c:IsRelateToEffect(e) and c:IsAbleToDeck() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=Duel.SelectMatchingCard(tp,s.tfil22,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,2,c)
		if #sg>0 then
			sg:AddCard(c)
			Duel.HintSelection(sg)
			Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
		end
	end
end
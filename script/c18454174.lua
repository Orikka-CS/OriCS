--되감기는 추억(푸른 실)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(18454166)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
	e2:SetLabelObject(e1)
	e2:SetLabel(id)
	c:RegisterEffect(e2)
end
s.listed_series={0xc04}
function s.tfil1(c)
	return c:IsSetCard(0xc04) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tfil1(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tfil1,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tfil1,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and ((tc:IsLocation(LOCATION_EXTRA) and  Duel.GetLocationCountFromEx(tp,tp,tc)>0)
			or (tc:IsLocation(LOCATION_DECK) and  Duel.GetLocationCount(tp,LOCATION_MZONE)>0))
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
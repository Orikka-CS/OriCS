--네크로워커 루나
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon procedure
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xc24),2,2)
	c:EnableReviveLimit()
	--묘지로 보내지는 몬스터는 묘지로는 가지 않으며 제외된다.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetTarget(s.rmtarget)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	--대상의 제외 상태인 몬스터를 특수 소환한다. 추가로, 대상 필드의 카드를 제외한다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0xc24}
function s.rmtarget(e,c)
	return not c:IsLocation(LOCATION_OVERLAY) and not c:IsSpellTrap() and Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),c)
end
function s.rmfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xc24) and c:IsAbleToRemove()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xc24) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
	e:SetLabelObject(g1:GetFirst())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc1,tc2=Duel.GetFirstTarget()
	if tc1~=e:GetLabelObject() then tc1,tc2=tc2,tc1 end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if tc2:IsRelateToEffect(e) and aux.nvfilter(tc2) then
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
		if tc1:IsRelateToEffect(e) then
			Duel.BreakEffect()
			Duel.Remove(tc1,POS_FACEUP,REASON_EFFECT)
		end
	end
end
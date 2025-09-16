--페넘브라 미스트리아
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xc11),aux.NOT(aux.FilterBoolFunctionEx(Card.IsSummonableCard)))
	--자신 필드의 "페넘브라" 카드를 임의의 수만큼 릴리스하고, 그 수만큼 상대 필드의 앞면 표시 몬스터의 컨트롤을 얻는다.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--그 몬스터를 특수 소환한다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.gysptg)
	e2:SetOperation(s.gyspop)
	c:RegisterEffect(e2)
end
s.listed_series={0xc11}
s.listed_names={id,99000417}
function s.rlfilter(c,tp,chk)
	return c:IsReleasableByEffect() and c:IsSetCard(0xc11)
		and (chk==1 or Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rlfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,chk)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAbleToChangeControler),tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
function s.rlrescon(sg,e,tp)
	return Duel.GetMZoneCount(tp,sg,tp,LOCATION_REASON_CONTROL)>=#sg
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local cg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAbleToChangeControler),tp,0,LOCATION_MZONE,nil)
	if #cg==0 then return end
	local rg=Duel.GetMatchingGroup(s.rlfilter,tp,LOCATION_ONFIELD,0,nil,tp,1)
	if #rg==0 then return end
	local g=aux.SelectUnselectGroup(rg,e,tp,1,#cg,s.rlrescon,1,tp,HINTMSG_RELEASE)
	if #g==0 or Duel.Release(g,REASON_EFFECT)==0 then return end
	local og=Duel.GetOperatedGroup()
	local ct=#og
	if ct==0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local sg=(cg-og):Select(tp,ct,ct,nil)
	if #sg==0 then return end
	Duel.HintSelection(sg)
	if Duel.GetControl(sg,tp)>0 then
		Duel.GetOperatedGroup():ForEach(Card.NegateEffects,c)
	end
end
function s.gyspfilter(c,e,tp)
	return c:IsSetCard(0xc11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.gysptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.gyspfilter(chkc,e,tp) end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>0
		and Duel.IsExistingTarget(s.gyspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local max=math.min(2,ft)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		or not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,99000417) then
		max=1
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.gyspfilter,tp,LOCATION_GRAVE,0,1,max,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,tp,0)
end
function s.gyspop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		if #g>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
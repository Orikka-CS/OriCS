--백루와 초상의 요화
local s,id=GetID()
function s.initial_effect(c)
	-----------------------------------------
	-- 융합 소환 조건
	-- "백루의 요화가" + 패의 몬스터 1장
	-----------------------------------------
	c:EnableReviveLimit()
	Fusion.AddProcMix(
    		c,true,true,
    		aux.FilterBoolFunctionEx(Card.IsSetCard,0xfa7),
    		aux.FilterBoolFunctionEx(Card.IsLocation,LOCATION_HAND)
	)
	-----------------------------------------
	-- ①: 자신 필드의 이 카드를 싱크로 소재로 할 경우,
	--    이 카드를 튜너 이외의 싱크로 몬스터로 취급
	-----------------------------------------
	-- 필드에서 싱크로 타입 부여
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a:SetCode(EFFECT_ADD_TYPE)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetValue(TYPE_SYNCHRO)
	c:RegisterEffect(e1a)
	-- 튜너가 아닌 것으로 취급
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE)
	e1b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1b:SetCode(EFFECT_NONTUNER)
	e1b:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e1b)

	-----------------------------------------
	-- ②: 묘지 / 제외 카드 1~3장 되돌리고
	--    되돌린 수만큼 레벨을 올리거나 내린다
	-----------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0)) -- 텍스트 id(0): 되돌리고 레벨 조정
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)

	-----------------------------------------
	-- ③: 자신 / 상대 턴에, 융합 소환한 이 카드를
	--    릴리스하고 발동. 덱에서 "요화" 몬스터 2장 특소
	-----------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1)) -- 텍스트 id(1): 덱에서 2장 특소
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

s.listed_names={124121114} -- "백루의 요화가"
s.listed_series={0xfa7}    -- "요화"

---------------------------------------------------
-- ② 되돌릴 카드 필터
---------------------------------------------------
function s.tdfilter(c)
	return c:IsAbleToDeck()
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.tdfilter(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(
			s.tdfilter,tp,
			LOCATION_GRAVE+LOCATION_REMOVED,
			LOCATION_GRAVE+LOCATION_REMOVED,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,
		LOCATION_GRAVE+LOCATION_REMOVED,
		LOCATION_GRAVE+LOCATION_REMOVED,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end

	local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if ct==0 then return end

	local lvl=c:GetLevel()
	local canUp=true
	local canDown=(lvl>ct)

	if not (canUp or canDown) then return end

	local op
	if canUp and canDown then
		-- id,2 : "레벨을 올린다", id,3 : "레벨을 내린다" 로 텍스트 세팅
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif canUp then
		op=0
	else
		op=1
	end

	local val=(op==0) and ct or -ct
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(val)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1)
end

---------------------------------------------------
-- ③ 조건 / 코스트 / 특소처리
---------------------------------------------------
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ph=Duel.GetCurrentPhase()
	-- 데미지 스텝(계산 전/후 모두)에서는 발동 불가
	if ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL then
		return false
	end
	return c:IsSummonType(SUMMON_TYPE_FUSION)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end

function s.yofilter(c,e,tp)
	return c:IsSetCard(0xfa7) and c:IsMonster()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.yofilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 실제 소환 수는 op에서 2장까지 조정
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		ft=1
	end
	ft=math.min(ft,2)
	if ft<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.yofilter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--고티스의 흐름 엔타렛
local s,id=GetID()

--------------------------------------------------
-- 메인 페이즈인지 확인하는 래퍼 (proc_workaround용)
--------------------------------------------------
local function IsInMainPhase()
	return Duel.IsMainPhase()
end

function s.initial_effect(c)
	--------------------------------------------------
	-- ① 패에서 퀵 발동 / 이 카드 + "고티스" 1장 제외하고 드로우
	--------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetCountLimit(1,id)
	e1:SetCondition(IsInMainPhase)     -- 자신/상대 메인 페이즈에만
	e1:SetCost(s.cost1)                -- 이 카드 + "고티스" 1장 제외
	e1:SetTarget(s.tar1)               -- 드로우 수 설정
	e1:SetOperation(s.op1)             -- 실제 드로우 처리
	c:RegisterEffect(e1)

	--------------------------------------------------
	-- ② 이 카드가 제외되었을 때 / 어류족 특소 + 자신 되돌리기
	--------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tar2) -- 특소 대상 설정
	e2:SetOperation(s.op2) -- 특소 + 자신 되돌리기
	c:RegisterEffect(e2)
end

-- "고티스" 시리즈
s.listed_series={SET_GHOTI}

--------------------------------------------------
-- ① 코스트 관련
--------------------------------------------------
-- 함께 제외할 "고티스" 카드 후보
--  - 패 / 묘지의 "고티스" 카드
--  - 패에서 제외하는 경우: 패에서 이 카드 + 고티스 2장 제외 → 2장 드로우 가능해야 함
--  - 묘지에서 제외하는 경우: 패에서 이 카드 1장만 제외 → 1장 드로우만 되면 됨
function s.cfil1(c,tp)
	if not c:IsSetCard(SET_GHOTI) then return false end
	if c:IsLocation(LOCATION_HAND) then
		-- 패에서 제외 → 총 패 2장 제외 → 2장 드로우 가능해야 함
		return Duel.IsPlayerCanDraw(tp,2)
	elseif c:IsLocation(LOCATION_GRAVE) then
		-- 묘지에서 제외 → 패는 이 카드 1장만 제외 → 1장 드로우면 충분
		return Duel.IsPlayerCanDraw(tp,1)
	end
	return false
end

-- 코스트: 패의 이 카드 + "고티스" 1장을 제외
-- 드로우할 장수는 e:SetLabel로 저장
--  - 기본적으로 이 카드(패) 1장 → 최소 1드로우
--  - 고티스를 패에서 제외했으면 총 2장 → 라벨 2
--  - 고티스를 묘지에서 제외했으면 패 카드는 이 카드만 → 라벨 1
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemoveAsCost()
			and Duel.IsExistingMatchingCard(
				s.cfil1,tp,
				LOCATION_HAND+LOCATION_GRAVE, -- ★ 필드 사용 X
				0,1,c,tp
			)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfil1,tp,
		LOCATION_HAND+LOCATION_GRAVE,0,1,1,c,tp)
	local tc=g:GetFirst()
	-- 고티스를 어디에서 제외했는지에 따라 드로우 장수 결정
	if tc:IsLocation(LOCATION_HAND) then
		e:SetLabel(2) -- 이 카드(패) + 고티스(패) → 패 2장 제외 → 2드로우
	else
		e:SetLabel(1) -- 이 카드(패) + 고티스(묘지) → 패 1장 제외 → 1드로우
	end
	-- 이 카드까지 코스트 그룹에 포함해 함께 제외
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

-- ① 타깃: 드로우 장수만 세팅
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end

-- ① 처리: 라벨 수만큼 드로우
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,e:GetLabel(),REASON_EFFECT)
end

--------------------------------------------------
-- ② 특수 소환 관련
--------------------------------------------------
-- 특소할 어류족 몬스터 후보
--  - 레벨 6 이하, 어류족
function s.tfil2(c,e,tp)
	return c:IsRace(RACE_FISH)
		and c:IsLevelBelow(6)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ② 타깃 설정
--  - 기본 특소 위치: 패 + 묘지
--  - 자신 필드에 몬스터가 없고 상대 필드에만 몬스터가 있을 경우:
--      덱에서도 특수 소환 가능 (엑스트라 덱은 사용 X)
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local loc=LOCATION_HAND+LOCATION_GRAVE

	-- 상대 필드에만 몬스터가 있을 경우 → 덱 추가
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)~=0 then
		loc=loc+LOCATION_DECK
	end

	if chk==0 then
		-- 몬스터 존 자리가 있어야 함
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		-- 해당 위치(loc)에 특소 가능한 몬스터가 있는지 체크
		return Duel.IsExistingMatchingCard(s.tfil2,tp,loc,0,1,nil,e,tp)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
	-- 이후 이 카드를 묘지로 보낼지 / 덱 맨 위로 올릴지 선택할 수 있다는 정보
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end

-- ② 처리:
--  1) 패/묘지(조건부 덱)에서 어류족 특소
--  2) 성공했다면 이 카드를
--     ● 묘지로 되돌리기(RETURN 취급) 혹은
--     ● 덱 맨 위로 되돌리기
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local loc=LOCATION_HAND+LOCATION_GRAVE

	-- 상대 필드에만 몬스터가 있을 경우 → 덱에서도 특소 가능
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)~=0 then
		loc=loc+LOCATION_DECK
	end

	-- 몬스터 존 자리가 없으면 특소 불가
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,
		aux.NecroValleyFilter(s.tfil2),tp,loc,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0
		and c:IsRelateToEffect(e) then
		-- [1] 묘지로 되돌린다 / [2] 덱 맨 위로 되돌린다
		local op=Duel.SelectEffect(tp,
			{true,aux.Stringid(id,0)},            -- "묘지로 되돌린다"
			{c:IsAbleToDeck(),aux.Stringid(id,1)} -- "덱 맨 위로 되돌린다"
		)
		if op==1 then
			Duel.SendtoGrave(c,REASON_EFFECT+REASON_RETURN)
		elseif op==2 then
			Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
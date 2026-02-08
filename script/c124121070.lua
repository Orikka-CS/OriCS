--흑린비갑
local s,id=GetID()
function s.initial_effect(c)
	----------------------------------------
	-- ① 발동 시: 묘지의 "붉은 눈" 몬스터 1장 특소 + 이 카드 장착
	--	+ 이 턴 동안 엑덱 특소 제한(붉은 눈 / 드래곤족만)
	----------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 이 카드명의 ①은 1턴에 1번
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	----------------------------------------
	-- ② 장착 몬스터 공격력 600 업 (장착 카드 존에서 1턴에 1번)
	----------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0)) -- "ATK 600 올린다" 같은 설명용 텍스트
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)		  -- 장착된 상태에서만 사용 가능
	e2:SetCountLimit(1)				  -- 카드당 1번 (이 부분은 필요하면 {id,2} 형태로 바꿀 수도 있음)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

	----------------------------------------
	-- ③ 묘지 발동: 덱에서 "붉은 눈" 몬스터 1장 서치
	--	→ 그 후, 묘지/제외의 "붉은 눈" 카드 3장(이 카드 포함)을 덱으로 되돌린다
	----------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)		  -- 묘지에서 발동
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,{id,1})		   -- 이 카드명의 ③은 1턴에 1번
	e3:SetTarget(s.tg3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end

----------------------------------------
-- ① 관련: 특수 소환 대상 ("붉은 눈" 몬스터, 묘지에서 특소 가능)
----------------------------------------
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3b)			-- "붉은 눈" 몬스터 군(SET_RED_EYES = 0x3b 가정)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ① 발동 시 타겟 지정: 묘지에서 "붉은 눈" 몬스터 1장 특소 준비
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 특소 1장 예고
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	-- 동시에 이 카드가 장착될 것이므로, 장착 처리도 같이 예고
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

-- ① 실제 처리: 특소 + 장착 + 엑덱 특소 제한 부여
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	-- 묘지에서 "붉은 눈" 몬스터 1장 선택 → 특수 소환
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 이 카드(흑린비갑)를 그 몬스터에 장착
		Duel.Equip(tp,c,tc)
		-- 장착 제한: 이 카드의 원래 장착 대상만 장착 가능하게 하는 안전장치
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		c:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()

	-- 이 턴 동안, 붉은 눈 / 드래곤족 이외의 엑덱 특소를 봉인
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(id,2)) -- "이 턴, 붉은 눈/드래곤족만 엑덱에서 특소 가능" 같은 설명용
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)

	-- “리저드 체크” : 드래곤족/붉은 눈 이외의 몬스터를 융합재료 등으로 쓰는 꼼수 방지용 공통 기믹
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
end

-- 장착 제한: 이 카드의 "주인" 몬스터에게만 장착 유지
function s.eqlimit(e,c)
	return e:GetOwner()==c
end

-- 엑덱 특소 제한: 드래곤족 / 붉은 눈 이외는 특소 불가
function s.splimit(e,c)
	return not c:IsRace(RACE_DRAGON)
		and not c:IsSetCard(0x3b)	   -- "붉은 눈" 세트 아님
		and c:IsLocation(LOCATION_EXTRA)
end

-- 리자드 체크용: 원래 종족/세트까지 확인해서 꼼수 제한
function s.lizfilter(e,c)
	return not c:IsOriginalRace(RACE_DRAGON)
		and not c:IsOriginalSetCard(0x3b)
end

----------------------------------------
-- ② 관련: 장착 몬스터 공격력 600 업
----------------------------------------
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 현재 이 카드가 장착되어 있는 몬스터가 존재해야 발동 가능
		return c:GetEquipTarget()~=nil
	end
	-- 따로 OperationInfo 는 필요 없음(단순 ATK 변경)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget() -- 이 카드가 장착되어 있는 몬스터
	if c:IsRelateToEffect(e) and ec and ec:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)				  -- 공격력 +600
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		ec:RegisterEffect(e1)
	end
end

-- ③: 묘지에서 발동 → "흑린비갑" 이외의 묘지/제외의 "붉은 눈" 카드 2장 + 이 카드 → 덱 아래
function s.tdfilter(c)
	return c:IsSetCard(SET_RED_EYES) and c:IsFaceup()
		and (c:IsAbleToDeck() or c:IsAbleToExtra())
end

function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	if chk==0 then
		-- 이 카드 이외의 붉은 눈 카드 2장이 필요
		return c:IsAbleToDeck()
			and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,2,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,2,2,c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g+c,3,tp,0)
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local tg=Duel.GetTargetCards(e)
	if #tg<2 then return end

	-- 2장 + 흑린비갑 자신 추가
	tg:AddCard(c)

	-- 덱 아래로 이동
	if Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
		local ct=Duel.GetOperatedGroup():Filter(Card.IsControler,nil,tp)
			:FilterCount(Card.IsLocation,nil,LOCATION_DECK)

		-- 2장 이상이면 순서 정렬 가능
		if ct>1 then
			Duel.SortDeckbottom(tp,tp,ct)
		end
	end
end
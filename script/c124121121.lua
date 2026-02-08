--요화의 식
local s,id=GetID()
function s.initial_effect(c)
	-----------------------------------------------------
	-- ① 덱에서 요화 몬스터 서치 → 관련 카드 묘지로
	-----------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)

	-----------------------------------------------------
	-- ② 묘지에서 발동: 요화 몬스터 3장 대상으로 특소 & 덱 되돌리기
	-----------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

s.listed_series={0xfa7}

-----------------------------------------------------
-- ① 덱에서 요화 몬스터 → 연관 카드 묘지로
-----------------------------------------------------
function s.tfil1(c)
	return c:IsSetCard(0xfa7) and c:IsMonster() and c:IsAbleToHand()
end
function s.ofil1(c,tc)
	return c:IsAbleToGrave() and c:ListsCode(tc:GetCode()) 
		and not c:IsOriginalCode(tc:GetOriginalCode())
end

function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tfil1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
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

-----------------------------------------------------
-- ② 조건: 릴리스된 카드 중 요화 몬스터가 있는가?
-----------------------------------------------------
function s.relfilter(c,tp)
	return c:IsSetCard(0xfa7) and c:IsMonster()
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.relfilter,1,nil,tp)
end

-----------------------------------------------------
-- ② 비용: 이 카드를 제외
-----------------------------------------------------
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end

-----------------------------------------------------
-- ② 대상: 묘지의 요화 몬스터 3장
-----------------------------------------------------
function s.yofil(c)
	return c:IsSetCard(0xfa7) and c:IsMonster() and c:IsAbleToDeck()
end

function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.yofil,tp,LOCATION_GRAVE,0,3,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.yofil,tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end

-----------------------------------------------------
-- ② 실행: 1장 특소 → 2장 덱으로
-----------------------------------------------------
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g<3 then return end

	-- 특수 소환할 1장 선택
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,1,nil)
	local sc=sg:GetFirst()

	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		g:RemoveCard(sc)
		-- 나머지 2장 덱으로 되돌림
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

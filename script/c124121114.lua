--백루의 요화가
local s,id=GetID()
function s.initial_effect(c)
	--------------------------------
	-- ①: 소환 / 묘지로 보내졌을 때 서치
	--------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCountLimit(1,id) -- 이 카드명의 ①은 1턴에 1번
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	c:RegisterEffect(e3)

	--------------------------------
	-- ②: 비드로우 몬스터가 패에 들어왔을 때, 릴리스 융합
	--------------------------------
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_HAND)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e4:SetDescription(aux.Stringid(id,1))
	-- 동일한 체인에서는 1번까지
	e4:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e4:SetCondition(s.con4)
	e4:SetCost(Cost.PayLP(200))
	e4:SetTarget(s.fustg)
	e4:SetOperation(s.fusop)
	c:RegisterEffect(e4)
end
s.listed_series={0xfa7}
s.listed_names={id}

--------------------------------
-- ① 서치
--------------------------------
function s.tfil1(c)
	return c:IsSetCard(0xfa7) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil1,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tfil1,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--------------------------------
-- ② 트리거 조건:
-- 드로우 이외의 방법으로 몬스터가 패에 들어왔을 때
--------------------------------
function s.nfil4(c)
	return c:IsMonster() and not c:IsReason(REASON_DRAW)
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.nfil4,1,nil)
end

--------------------------------
-- ② 융합 관련 헬퍼
--------------------------------

-- 융합 소재로 쓸 우리 쪽 패/필드 몬스터
-- 패/필드 모두 "릴리스 가능한 상태"여야 하고, 융합 소재 가능해야 함
function s.matfilter(c,e)
	return c:IsMonster()
		and c:IsCanBeFusionMaterial()
		and not c:IsImmuneToEffect(e)
		and c:IsReleasableByEffect(e)
end

-- "요화" 융합 몬스터 (CheckFusionMaterial 사용 X, 단순 필터)
function s.fusfilter(c,e,tp)
	return c:IsSetCard(0xfa7) and c:IsType(TYPE_FUSION)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end

------------------------------------------------
-- ② 타겟: 실제로 융합 소환이 가능한지 체크
------------------------------------------------
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,e)
		if #mg==0 then return false end

		local chkf=tp
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			chkf=PLAYER_NONE
		end

		-- 엑덱의 "요화" 융합 몬스터 중 실제 융합 가능한 카드가 있는지 체크
		local exg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
		return exg:IsExists(function(fc)
			return fc:CheckFusionMaterial(mg,nil,chkf)
		end,1,nil)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_FUSION_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- 실제 융합 처리
-- 선택한 소재 전부를 "릴리스" + "융합 소재"로 처리
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end

	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,e)
	if #mg==0 then return end

	local chkf=tp
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		chkf=PLAYER_NONE
	end

	-- 소환 가능한 요화 융합 몬스터들
	local sg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #sg==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=sg:Select(tp,1,1,nil):GetFirst()
	if not tc then return end

	-- 융합 소재 선택
	local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
	if #mat==0 then return end

	tc:SetMaterial(mat)

	-- 패/필드 관계없이 전부 릴리스 + 융합 소재 처리
	Duel.Release(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)

	Duel.BreakEffect()
	if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end

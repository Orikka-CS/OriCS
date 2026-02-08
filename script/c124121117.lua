--청명한 폭포의 요화
local s,id=GetID()

function s.initial_effect(c)

	---------------------------------------------------------
	-- ① 패 공개 → 패/필드 요화 몬스터를 융합소재로 릴리스하여 융합소환
	---------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetCost(Cost.SelfReveal) -- 패에서 공개
	e1:SetTarget(s.fustg)
	e1:SetOperation(s.fusop)
	c:RegisterEffect(e1)

	---------------------------------------------------------
	-- ② 릴리스되어 묘지/제외로 갔을 때
	---------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.relcon)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

s.listed_series={0xfa7}

---------------------------------------------------------
-- ① 조건: 자신/상대 메인 페이즈
---------------------------------------------------------
function s.con1(e,tp)
	return Duel.GetCurrentPhase()&(PHASE_MAIN1|PHASE_MAIN2)~=0
end

---------------------------------------------------------
-- ① 융합 소재 필터 (요화 몬스터 + 릴리스 가능)
---------------------------------------------------------
function s.matfilter(c,e)
	return c:IsSetCard(0xfa7)
		and c:IsMonster()
		and c:IsCanBeFusionMaterial()
		and not c:IsImmuneToEffect(e)
		and c:IsReleasableByEffect(e)
end

---------------------------------------------------------
-- ① 융합 몬스터 필터
--    레벨 9 이상의 융합 몬스터만
---------------------------------------------------------
function s.fusfilter(c,e,tp)
	return c:IsType(TYPE_FUSION)
		and c:IsLevelAbove(9)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end

---------------------------------------------------------
-- ① 타겟 설정: 반드시 이 카드가 융합 소재에 포함되어야 함
--     + 실제로 융합 가능한 레벨 9 이상 융합이 있는지 체크
---------------------------------------------------------
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		-- ① 이 카드 자체가 소재로 사용 가능해야 함
		if not s.matfilter(c,e) then return false end

		-- ② 패/필드의 요화 몬스터 재료 풀
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,e)
		if not mg:IsContains(c) then return false end

		-- ③ 레벨 9 이상 융합 몬스터 중 실제로 융합 가능한지 검사
		local chkf=tp
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			chkf=PLAYER_NONE
		end

		local exg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
		return exg:IsExists(function(fc)
			return fc:CheckFusionMaterial(mg,c,chkf)
		end,1,nil)
	end

	-- 발동 가능하면 여기까지 도달함
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_FUSION_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

---------------------------------------------------------
-- ① 실제 융합 처리 (요화 몬스터 + 반드시 이 카드 포함 → 릴리스)
---------------------------------------------------------
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,e)
	if #mg==0 or not mg:IsContains(c) then return end

	local chkf=tp
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		chkf=PLAYER_NONE
	end

	local sg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #sg==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=sg:Select(tp,1,1,nil):GetFirst()
	if not tc then return end

	-- 반드시 이 카드를 포함한 소재 선택
	local mat=Duel.SelectFusionMaterial(tp,tc,mg,c,chkf)
	if #mat==0 then return end

	tc:SetMaterial(mat)

	for mc in mat:Iter() do
		mc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1) -- 릴리스 판정용
	end

	Duel.Release(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)

	Duel.BreakEffect()
	if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end

---------------------------------------------------------
-- ② 릴리스 되어 묘지/제외 갔을 경우
---------------------------------------------------------
function s.relcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_RELEASE)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED))
end

---------------------------------------------------------
-- ② 선택지 필터
---------------------------------------------------------

-- "융합이 아닌 요화 몬스터"
function s.tfil21(c,e,tp)
	return c:IsSetCard(0xfa7)
		and c:IsMonster()
		and not c:IsType(TYPE_FUSION)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- 상대 몬스터 회수
function s.tfil22(c)
	return c:IsMonster() and c:IsFaceup() and c:IsAbleToHand()
end

---------------------------------------------------------
-- ② 타겟
---------------------------------------------------------
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.tfil21,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b2=Duel.IsExistingMatchingCard(s.tfil22,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,nil)

	if chk==0 then return b1 or b2 end

	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)}
	)

	e:SetLabel(op)

	if op==1 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	end
end

---------------------------------------------------------
-- ② 실행
---------------------------------------------------------
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()

	if op==1 then
		-- 요화 몬스터 특수 소환
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tfil21),
			tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end

	elseif op==2 then
		-- 상대 묘지/제외 몬스터 패로
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tfil22),
			tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			local p=tp
			if tc:IsAbleToExtra() then
				p=nil
			end
			Duel.SendtoHand(g,p,REASON_EFFECT)
		end
	end
end
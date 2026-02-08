--설폭의 요화루
local s,id=GetID()
function s.initial_effect(c)
	--------------------------------
	-- ①: 필드 보호
	--------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 공격 대상으로 할 수 없음
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tar2)
	c:RegisterEffect(e2)
	-- 효과의 대상으로 할 수 없음
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)

	--------------------------------
	-- ②: "요화" 파괴 대체 (1턴에 1번)
	--------------------------------
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id) -- 이 카드명의 ②는 1턴에 1번
	e4:SetValue(s.val4)
	e4:SetTarget(s.tar4)
	e4:SetOperation(s.op4)
	c:RegisterEffect(e4)

	--------------------------------
	-- ③: 패 / 덱 몬스터를 릴리스 취급으로 융합 (1턴에 1번)
	--------------------------------
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e5:SetCountLimit(1,{id,1}) -- 이 카드명의 ③은 1턴에 1번
	e5:SetTarget(s.fustg)
	e5:SetOperation(s.fusop)
	c:RegisterEffect(e5)
end

-- "요화" 시리즈
s.listed_series={0xfa7}

--------------------------------
-- ① 관련
--------------------------------
function s.nfil2(c)
	return c:IsType(TYPE_FUSION) and c:IsLevelAbove(2)
end
function s.con2(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.nfil2,tp,LOCATION_MZONE,0,1,nil)
end
function s.tar2(e,c)
	-- 레벨 1 또는 10인 자신 몬스터
	return c:IsControler(e:GetHandlerPlayer()) and (c:IsLevel(1) or c:IsLevel(10))
end

--------------------------------
-- ② 파괴 대체
--------------------------------
function s.vfil4(c,tp)
	return c:IsSetCard(0xfa7) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
		and c:IsControler(tp) and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
end
function s.val4(e,c)
	local tp=e:GetHandlerPlayer()
	return s.vfil4(c,tp)
end
-- 대신 보낼 패의 몬스터
function s.tfil4(c)
	return c:IsMonster() and c:IsAbleToGrave()
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return eg:IsExists(s.vfil4,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.tfil4,tp,LOCATION_HAND,0,1,nil)
	end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local tg=Duel.SelectMatchingCard(tp,s.tfil4,tp,LOCATION_HAND,0,1,1,nil)
		local tc=tg:GetFirst()
		e:SetLabelObject(tc)
		return true
	end
	return false
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,1-tp,id)
	local tc=e:GetLabelObject()
	-- 패 몬스터를 "릴리스" 취급으로 묘지로 보냄
	if tc then
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REPLACE+REASON_RELEASE)
	end
end

--------------------------------
-- ③ 융합 관련 헬퍼
--------------------------------

-- 융합 소재로 쓸 패 / 덱 몬스터
function s.fusmatfilter(c,e)
	return c:IsMonster() and c:IsCanBeFusionMaterial()
		and not c:IsImmuneToEffect(e)
		and c:IsAbleToGrave()
end

-- "요화" 융합 몬스터 (간단 필터: CheckFusionMaterial 사용 안 함)
function s.yofusfilter(c,e,tp)
	return c:IsSetCard(0xfa7) and c:IsType(TYPE_FUSION)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end

------------------------------------------------
-- ③ 타겟: 실제로 융합 소환 가능한지 체크
------------------------------------------------
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(s.fusmatfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e)
		if #mg==0 then return false end

		local chkf=tp
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			chkf=PLAYER_NONE
		end

		-- 실제 융합 가능한 요화 융합 몬스터가 있는지 확인
		local exg=Duel.GetMatchingGroup(s.yofusfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
		return exg:IsExists(function(fc)
			return fc:CheckFusionMaterial(mg,nil,chkf)
		end,1,nil)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_FUSION_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_HAND+LOCATION_DECK)
end

-- ③ 실제 융합 처리
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end

	local mg=Duel.GetMatchingGroup(s.fusmatfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e)
	if #mg==0 then return end

	local chkf=tp
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		chkf=PLAYER_NONE
	end

	local sg=Duel.GetMatchingGroup(s.yofusfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #sg==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=sg:Select(tp,1,1,nil):GetFirst()
	if not tc then return end

	-- 융합 소재 선택
	local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
	if #mat==0 then return end
	tc:SetMaterial(mat)

	-- 패 / 덱 소재를 전부 "릴리스" 취급으로 묘지로 보냄
	Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION+REASON_RELEASE)

	Duel.BreakEffect()
	if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end
--요화의 묵
local s,id=GetID()
function s.initial_effect(c)
	----------------------------------------
	-- ① 마/함 발동 무효 + 파괴 후 패로
	----------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)

	----------------------------------------
	-- ② 묘지에서 융합 + ATK 상승
	----------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish) -- 묘지의 이 카드 제외
	e2:SetTarget(s.fustg)
	e2:SetOperation(s.fusop)
	c:RegisterEffect(e2)
end

s.listed_series={0xfa7}
s.listed_names={124121114} -- "백루의 요화가"

----------------------------------------
-- ① 관련
----------------------------------------
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end

function s.tfil1(c)
	return c:IsFaceup() and (c:IsCode(124121114)
		or (c:IsLocation(LOCATION_MZONE) and c:IsLevelAbove(9) and c:IsSetCard(0xfa7)))
end

function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil1,tp,LOCATION_ONFIELD,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		if Duel.Destroy(eg,REASON_EFFECT)>0 and rc:IsAbleToHand()
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.SendtoHand(eg,tp,REASON_EFFECT)
		end
	end
end

----------------------------------------
-- ② 융합 관련
----------------------------------------

-- 융합 소재: 우리 필드/패 몬스터 아무거나
function s.fusmatfilter(c,e)
	return c:IsMonster()
		and c:IsCanBeFusionMaterial()
		and not c:IsImmuneToEffect(e)
		and c:IsReleasableByEffect(e) -- 릴리스 가능한 상태
end

-- "요화" 융합 몬스터 (단순 필터)
function s.fusfilter(c,e,tp)
	return c:IsSetCard(0xfa7) and c:IsType(TYPE_FUSION)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end

-- ② 타깃: 실제로 융합 소환 가능한지 완전 체크
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 소재 후보
		local mg=Duel.GetMatchingGroup(s.fusmatfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,e)
		if #mg==0 then return false end

		local chkf=tp
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			chkf=PLAYER_NONE
		end

		-- 실제 융합 가능한 "요화" 융합 몬스터가 있는지 검사
		local exg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
		return exg:IsExists(function(fc)
			return fc:CheckFusionMaterial(mg,nil,chkf)
		end,1,nil)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_FUSION_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- ② 실제 융합 처리
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 필드가 가득 찼고 59822133까지 있으면 어차피 실패
	end

	local mg=Duel.GetMatchingGroup(s.fusmatfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,e)
	if #mg==0 then return end

	local chkf=tp
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		chkf=PLAYER_NONE
	end

	local sg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #sg==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=sg:Select(tp,1,1,nil):GetFirst()
	if not tc then return end

	-- 융합 소재 선택
	local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
	if #mat==0 then return end
	tc:SetMaterial(mat)

	-- 패/필드 몬스터를 융합 소재로서 릴리스
	Duel.Release(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)

	Duel.BreakEffect()
	if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)<=0 then
		return
	end
	tc:CompleteProcedure()

	-- 그 후, 패가 존재하면 패 매수 × 400 ATK 상승
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if ct>0 and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*400)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
end
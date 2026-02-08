--깨끗한 설원의 요화
local s,id=GetID()
function s.initial_effect(c)

	--------------------------------
	-- ①: 요화 마/함 세트 + 자기 자신 패로
	--------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)

	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	--------------------------------
	-- ②: 릴리스되어 묘지/제외 → 효과 발동
	--------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_TOHAND)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.relcon)
	e3:SetTarget(s.tar3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end

s.listed_series={0xfa7}

--------------------------------
-- ① 요화 마/함 세트
--------------------------------
function s.tfil1(c)
	return c:IsSetCard(0xfa7) and c:IsSpellTrap() and c:IsSSetable()
end

function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil1,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil)
	end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.tfil1,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
	
	if #g>0 and Duel.SSet(tp,g)>0
		and c:IsRelateToEffect(e) and c:IsAbleToHand()
		and Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,2)) then

		Duel.BreakEffect()
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end

--------------------------------
-- ② 릴리스되었고, 묘지/제외로 이동했을 때
--------------------------------
function s.relcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 반드시 "릴리스"되어야 하며
	-- 그 이동 위치가 "묘지 또는 제외"여야 함
	return c:IsReason(REASON_RELEASE)
	   and (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED))
end

--------------------------------
-- ② 효과 선택지
--------------------------------

-- 공격 표시 + 무효화 가능 몬스터
function s.tfil31(c)
	return c:IsNegatableMonster() and c:IsAttackPos()
end

-- 상대 묘지/제외 몬스터
function s.tfil32(c)
	return c:IsMonster() and c:IsFaceup() and c:IsAbleToHand()
end

function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.tfil31,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.tfil32,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,nil)

	if chk==0 then return b1 or b2 end

	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)}, -- 무효화
		{b2,aux.Stringid(id,1)}  -- 패로 회수
	)
	e:SetLabel(op)

	if op==1 then
		e:SetCategory(CATEGORY_DISABLE)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,LOCATION_MZONE)
	else
		e:SetCategory(CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	end
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()

	if op==1 then
		-- 무효화
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local g=Duel.SelectMatchingCard(tp,s.tfil31,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			tc:NegateEffects(e:GetHandler(),RESET_PHASE|PHASE_END)
		end

	elseif op==2 then
		-- 상대 묘지/제외 몬스터 패로
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tfil32),tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			-- 기본적으로는 내 패로 가져온다
			local p=tp
			-- 만약 엑스트라 덱으로 되돌아가야 하는 카드면(융합/싱크로/엑시즈/링크 등)
			-- 원래 주인의 엑스트라 덱으로 보내기 위해 p=nil 처리
			if tc:IsAbleToExtra() then
				p=nil
			end
			Duel.SendtoHand(g,p,REASON_EFFECT)
		end
	end
end
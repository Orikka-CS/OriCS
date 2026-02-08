--하얀 달의 요화
local s,id=GetID()
function s.initial_effect(c)

	--------------------------------
	-- ①: 덱/묘지 "요화" 특소 + 자신 회수
	--------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)

	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	--------------------------------
	-- ②: 릴리스되어 묘지 or 제외 → 선택 효과 발동
	--------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.relcon)
	e3:SetTarget(s.tar3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)

end

s.listed_series={0xfa7}
s.listed_names={id}

--------------------------------
-- ①: 특수 소환 후, 자신 패로
--------------------------------
function s.tfil1(c,e,tp)
	return c:IsSetCard(0xfa7)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not c:IsCode(id)
end

function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.tfil1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(
		tp,
		aux.NecroValleyFilter(s.tfil1),
		tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp
	)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0
		and c:IsRelateToEffect(e) and c:IsAbleToHand()
		and Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,2)) then

		Duel.BreakEffect()
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end

--------------------------------
-- ②: 릴리스되어 묘지 / 제외 → 발동
--------------------------------
function s.relcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_RELEASE)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED))
end

--------------------------------
-- ② 효과 선택지
--------------------------------
function s.tfil3(c)
	return c:IsMonster() and c:IsFaceup() and c:IsAbleToHand()
end

function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1 = Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local b2 = Duel.IsExistingMatchingCard(s.tfil3,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,nil)

	if chk==0 then return b1 or b2 end

	local op = Duel.SelectEffect(tp,
		{b1, aux.Stringid(id,0)}, -- 파괴
		{b2, aux.Stringid(id,1)}  -- 패로 회수
	)
	e:SetLabel(op)

	if op==1 then
		local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		e:SetCategory(CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	else
		e:SetCategory(CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	end
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()

	if op==1 then
		-- 마/함 파괴
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end

	elseif op==2 then
		-- 상대 묘지/제외 몬스터 패로
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tfil3),tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil)
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

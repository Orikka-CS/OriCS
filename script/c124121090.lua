-- 홍옥의 엄니
local s,id=GetID()
function s.initial_effect(c)
	------------------------------------------
	-- ① 패에서 버리고 서치
	------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))				-- 효과 텍스트 번호(①)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)	  -- 덱에서 패로 서치
	e2:SetType(EFFECT_TYPE_IGNITION)					 -- 자신 메인 페이즈에 발동하는 통상 효과
	e2:SetRange(LOCATION_HAND)						   -- 패에서 발동
	e2:SetCountLimit(1,id)							   -- 이 카드명의 ①은 1턴에 1번
	e2:SetCost(s.thcost)								 -- 코스트: 이 카드 자신을 버림
	e2:SetTarget(s.thtg)								 -- 서치 대상 지정
	e2:SetOperation(s.thop)							  -- 실제 서치 처리
	c:RegisterEffect(e2)

	------------------------------------------
	-- ② 상대 턴에 패 / 묘지에서 장착 마법처럼 장착
	------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)					  -- 속공 효과
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)			-- 패 / 묘지에서 발동 가능
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)			  -- 몬스터를 대상으로 함
	e2:SetCategory(CATEGORY_EQUIP)					   -- 장착 관련
	e2:SetCountLimit(1,{id,1})						   -- 이 카드명의 ②는 1턴에 1번
	e2:SetCondition(s.eqcon)							 -- 조건: 상대 턴
	e2:SetCost(s.eqcost)								 -- 코스트: 자필드 앞면 S/T 1장 묘지로
	e2:SetTarget(s.eqtg)								 -- 대상: 자신의 붉은 눈 몬스터 1장
	e2:SetOperation(s.eqop)							  -- 처리: 이 카드를 ATK 상승 장착마법으로 장착
	c:RegisterEffect(e2)

	------------------------------------------
	-- ③ 장착 몬스터가 파괴될 경우, 대신 이 카드가 패로 되돌아감 (파괴 치환)
	------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS) -- 장착 상태에서 지속적으로 작동
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)				   -- 파괴 대체 효과
	e3:SetTarget(s.reptg)								-- 파괴를 대신할지 여부를 결정
	c:RegisterEffect(e3)
end

-- "붉은 눈의 흉격"(Red-Eyes Fang with Chain) & "홍옥의 패" 카드명 등록
s.listed_names={32566831,124121071}

----------------------------------------------------------
-- ③ 파괴 대체: 장착 몬스터가 파괴될 때 대신 이 카드가 패로 돌아감
----------------------------------------------------------
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()	   -- 이 카드(홍옥의 엄니)
	local ec=c:GetEquipTarget()  -- 현재 이 카드가 장착되어 있는 몬스터
	if chk==0 then
		-- 장착 몬스터가 이미 다른 치환 효과(REASON_REPLACE)로 처리 중이 아니고
		-- 이 카드가 패로 되돌아갈 수 있으며
		-- 아직 파괴 확정 상태(STATUS_DESTROY_CONFIRMED)가 아닌지 체크
		return ec and not ec:IsReason(REASON_REPLACE)
			and c:IsAbleToHand() and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
	end
	-- 파괴를 대신해서 이 카드를 패로 되돌림
	Duel.SendtoHand(c,nil,REASON_EFFECT)
	-- true를 반환하여 장착 몬스터의 파괴를 치환했다는 것을 알림
	return true
end

----------------------------------------------------------
-- ① 코스트: 이 카드를 패에서 버림
----------------------------------------------------------
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end		  -- 패에서 버릴 수 있는지 확인
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)	   -- 코스트로 자신을 버림
end

----------------------------------------------------------
-- ① 서치 대상: "붉은 눈의 흉격"(32566831) 또는 "홍옥의 패"(124121071)
----------------------------------------------------------
function s.thfilter(c)
	return c:IsCode(32566831,124121071) and c:IsAbleToHand()
end

----------------------------------------------------------
-- ① 대상 지정: 덱에 서치 가능한 카드가 있는지 확인
----------------------------------------------------------
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	-- "덱에서 1장 패에 넣는다" 정보 설정
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

----------------------------------------------------------
-- ① 처리: 덱에서 해당 카드를 1장 서치
----------------------------------------------------------
function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)	 -- 패에 넣고
		Duel.ConfirmCards(1-tp,g)			   -- 상대에게 공개
	end
end

----------------------------------------------------------
-- ② 발동 조건: 상대 턴에만 발동 가능
----------------------------------------------------------
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

----------------------------------------------------------
-- ② 코스트로 보낼 카드: 자신의 마/함 존 앞면 카드(자기 자신 제외)
----------------------------------------------------------
function s.costfilter(c)
	return c:IsFaceup()		  -- 앞면 표시
		and not c:IsCode(id)	 -- 이 카드(홍옥의 엄니)는 제외
		and c:IsAbleToGraveAsCost()
end
function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_SZONE,0,1,nil)
	end
	-- 코스트로 보낼 카드 선택 → 묘지로 보냄
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

----------------------------------------------------------
-- ② 장착 대상: 자신의 필드의 앞면 표시 "붉은 눈" 몬스터
----------------------------------------------------------
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3b)   -- "붉은 눈" 세트(0x3b)
end

----------------------------------------------------------
-- ② 타깃 지정: 자신 필드의 "붉은 눈" 몬스터 1장
----------------------------------------------------------
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
			and chkc:IsControler(tp)
			and s.filter(chkc)
	end
	if chk==0 then
		-- S/T 존에 장착할 공간이 있고, 필드에 대상이 되는 붉은 눈 몬스터가 있는지 확인
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>=0
			and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 이 카드가 장착될 것이라는 정보 설정
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

----------------------------------------------------------
-- ② 처리: 패 / 묘지의 이 카드를 장착 마법처럼 장착 + ATK 상승
----------------------------------------------------------
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- (혹시 몬스터로 필드에 나와 있는 상태에서 뒷면이면 무효)
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end

	local tc=Duel.GetFirstTarget()
	-- 장착할 공간이 없거나, 대상 몬스터가 무효가 된 경우 → 이 카드는 그냥 묘지로
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0
		or tc:GetControler()~=tp
		or tc:IsFacedown()
		or not tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end

	-- 이 카드를 장착 마법처럼 그 몬스터에 장착
	Duel.Equip(tp,c,tc,true)

	-- 장착 제한: 선택한 몬스터에게만 장착 가능
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetLabelObject(tc)
	e1:SetValue(s.eqlimit)
	c:RegisterEffect(e1)

	-- 장착 몬스터 ATK 상승 효과
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)					-- 현재 800 상승 
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end

-- 장착 제한: 처음 선택한 몬스터에게만 장착 유지
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
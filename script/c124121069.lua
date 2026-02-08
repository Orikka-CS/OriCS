-- 붉은 눈의 혁기사-페이탈 기어프리드
local s,id=GetID()

function s.initial_effect(c)

	----------------------------------------------------------------------
	-- ① 패에서 버리고 발동
	--  패에서 이 카드를 코스트로 버리고,
	--  덱에서 "흑린비갑" 1장 + 레벨6 이하 레드아이즈 몬스터 1장을 서치 후
	--  패 1장 버린다.
	----------------------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)  -- 패로 넣는 효과
	e1:SetType(EFFECT_TYPE_IGNITION)				 -- 자신의 메인 페이즈에 발동
	e1:SetRange(LOCATION_HAND)					 -- 패에서 발동 가능
	e1:SetCountLimit(1,id)						 -- ①는 1턴 1번
	e1:SetCost(s.lvcost)							 -- 코스트 = 이 카드 버리기
	e1:SetTarget(s.sptg)							 -- 서치 타겟 지정
	e1:SetOperation(s.spop)					   -- 서치 처리
	c:RegisterEffect(e1)

	----------------------------------------------------------------------
	-- ② 특수 소환 성공 시 발동
	--  자신 필드의 "붉은 눈" 몬스터 1장을 지정하고,
	--  패/덱에서 레벨 6 이하의 "붉은 눈" 몬스터 1장을 장착 마법 취급으로 장착.
	----------------------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)				 -- 장착 효과
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)			 -- 특소 성공 시 트리거
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,{id,1})					 -- ②도 1턴 1번
	e2:SetTarget(s.eqtg)							 -- 장착 대상 지정
	e2:SetOperation(s.eqop)					   -- 장착 처리
	c:RegisterEffect(e2)

	----------------------------------------------------------------------
	-- ③ 다른 카드의 효과가 발동했을 때 발동 (Quick Effect)
	--  자신 필드에 다른 "붉은 눈" 카드가 존재하면,
	--  자신 필드 카드 1장 + 필드 카드 1장을 파괴한다.
	----------------------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)			   -- 속공 효과
	e2:SetCode(EVENT_CHAINING)					-- 체인이 발생할 때
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)						   -- ③ 역시 1턴 1번
	e2:SetCondition(s.thcon)						 -- 조건: 다른 카드의 효과여야 함
	e2:SetTarget(s.thtg)							 -- 파괴 대상 지정
	e2:SetOperation(s.thop)					   -- 파괴 처리
	c:RegisterEffect(e2)
end

-- "흑린비갑" 카드번호 등록
s.listed_names={124121070}

----------------------------------------------------------------------
-- ① 코스트: 이 카드 자체를 버린다.
----------------------------------------------------------------------
function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_DISCARD)
end

----------------------------------------------------------------------
-- ① 덱에서 가져올 '레벨 6 이하 붉은 눈 몬스터' 필터
----------------------------------------------------------------------
function s.Level4Beast(c)
	return c:IsLevelBelow(6)
		and c:IsSetCard(SET_RED_EYES)
		and c:IsAbleToHand()
end

-- ① 덱에서 가져올 "흑린비갑"
function s.spfilter(c)
	return c:IsAbleToHand() and c:IsCode(124121070)
end

----------------------------------------------------------------------
-- ① 타깃 설정: 둘 다 덱에 있어야 발동 가능
----------------------------------------------------------------------
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.Level4Beast,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK) -- 2장을 패로
end

----------------------------------------------------------------------
-- ① 처리: 흑린비갑 1장 + 레드아이즈 몬스터 1장 서치
--	   → 패 1장 버림
----------------------------------------------------------------------
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 중간에 카드가 없어졌을 수 있으므로 다시 체크
	if not (Duel.IsExistingMatchingCard(s.Level4Beast,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil)) then
		return
	end

	-- 흑린비갑 선택
	local tg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 레벨 6 이하 붉은 눈 몬스터 선택
	local g2=Duel.SelectMatchingCard(tp,s.Level4Beast,tp,LOCATION_DECK,0,1,1,nil)

	tg:Merge(g2) -- 합쳐서 한 번에 패로
	Duel.SendtoHand(tg,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tg)
	Duel.ShuffleHand(tp)

	-- 패 1장 버리기
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
	if #dg>0 then
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end

----------------------------------------------------------------------
-- ② 장착 효과 관련
----------------------------------------------------------------------

-- 장착 대상으로 가능한 조건 = 앞면 표시 "붉은 눈" 몬스터
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3b)
end

-- ② 타깃 설정: 대상 몬스터 + 장착할 "붉은 눈" 몬스터가 있어야 함
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then 
		return chkc:IsLocation(LOCATION_MZONE)
			and chkc:IsControler(tp)
			and s.filter(chkc)
	end

	if chk==0 then 
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end

-- 장착할 카드 = 레벨6 이하의 붉은 눈
function s.eqfilter(c)
	return c:IsSetCard(0x3b)
		and c:IsLevelBelow(6)
		and not c:IsForbidden() -- 장착 불가 카드 제외
end

----------------------------------------------------------------------
-- ② 처리: 붉은 눈 몬스터를 장착 마법 취급으로 장착
----------------------------------------------------------------------
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 마법/함정존 빈 자리가 없다면 불가
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end

	local tc=Duel.GetFirstTarget() -- 장착 대상 몬스터

	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

	-- 장착할 몬스터 선택
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local eq=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	local eqc=eq:GetFirst()

	-- 장착 처리
	if eqc and Duel.Equip(tp,eqc,tc,true) then
		-- Equip Limit 설정: 지정된 몬스터에게만 장착 유지
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(tc)
		eqc:RegisterEffect(e1)
	end
end

-- 장착 제한: 이 카드만 장착 가능
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

----------------------------------------------------------------------
-- ③ 조건: 다른 카드의 효과 발동 시 (즉, 자신 효과 X)
----------------------------------------------------------------------
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler()
end

-- 필드의 레드아이즈 존재 체크
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_RED_EYES)
end

-- 두 장 중 하나는 반드시 자신 필드 카드여야 한다는 조건
function s.rescon2(sg,e,tp,mg)
	return sg:IsExists(Card.IsControler,1,nil,tp)
end

----------------------------------------------------------------------
-- ③ 타깃 설정: 자신 필드 1장 + 필드의 다른 카드 1장을 선택
----------------------------------------------------------------------
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)

	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
			and aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon2,0)
	end

	Duel.SetOperationInfo(0,CATEGORY_DESTROY,rg,2,0,0)
end

----------------------------------------------------------------------
-- ③ 처리: 선택된 카드 2장 파괴
----------------------------------------------------------------------
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)

	-- 2장을 고르되: 반드시 자신 필드 카드 1장은 포함되어야 함
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon2,1,tp,HINTMSG_DESTROY)

	if #g==2 then
		Duel.HintSelection(g,true)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
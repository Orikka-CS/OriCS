-- 비블리오필림 오브 알렉산드리아
local s,id=GetID()

function s.initial_effect(c)
	-- ①: 순차 선택형 서치 (발동 시 코스트로 릴리스)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)

	-- ②: 묘지 회수 (엔드 페이즈)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cost2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

-- 릴리스 파트너 필터
function s.relfilter(c,tp)
	return c:IsRace(RACE_FAIRY) and c:IsLevelBelow(5) and c:IsReleasable()
		and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_DECK,0,1,nil,RACE_FAIRY)
end

-- 서치 대상 필터 (정확한 레벨 일치)
function s.thfilter(c,lv)
	return c:IsRace(RACE_FAIRY) and c:IsLevel(lv) and (c:IsAbleToHand() or c:IsAbleToGrave())
end

function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- Parameter 7 오류 방지를 위해 nil 사용
	if chk==0 then 
		return c:IsReleasable() 
			and Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c,tp) 
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	-- Parameter 3 nil 방지
	local g=Duel.SelectMatchingCard(tp,s.relfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,c,tp)
	local tc=g:GetFirst()
	
	-- 레벨 정보를 안전하게 넘김 (산술 오류 방지)
	local lv1=c:GetLevel()
	local lv2=tc:GetLevel()
	e:SetLabel(lv1, lv2)
	
	-- 코스트로 즉시 릴리스
	g:AddCard(c)
	Duel.Release(g,REASON_COST)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	-- Label에서 저장된 레벨 추출
	local lv1, lv2 = e:GetLabel()
	if not lv1 or not lv2 then return end
	local lvsum = lv1 + lv2
	
	-- 덱에 해당 레벨의 카드가 있는지 체크
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,lv1)
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,lv2)
	local b3=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,lvsum)
	
	local ops={}
	local sel={}
	
	-- 스트링 0, 1, 2번을 순차적으로 매칭
	if b1 then table.insert(ops,aux.Stringid(id,0)) table.insert(sel,lv1) end
	if b2 then table.insert(ops,aux.Stringid(id,1)) table.insert(sel,lv2) end
	if b3 then table.insert(ops,aux.Stringid(id,2)) table.insert(sel,lvsum) end
	
	if #ops==0 then return end
	
	-- 플레이어 선택창 팝업
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local target_lv=sel[op]
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,target_lv)
	if #g>0 then
	local tc=g:GetFirst()
	aux.ToHandOrElse(tc,tp)
	end
end

-- ②번 효과: 묘지 회수 (Parameter 3 nil 방지)
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,1,c,RACE_FAIRY) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsRace,tp,LOCATION_GRAVE,0,1,1,c,RACE_FAIRY)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then 
		Duel.SendtoHand(c,nil,REASON_EFFECT) 
	end
end
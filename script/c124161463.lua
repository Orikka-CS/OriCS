--브릿지버스터 시마론
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c)
	return c:IsSetCard(0xf3e) and c:IsTrap() and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleDeck(tp)
			local dg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_HAND,0,nil)
			if #dg>0 then
				Duel.BreakEffect()
				local dsg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
				Duel.SendtoGrave(dsg,REASON_EFFECT)
			end
		end
	end
end

--effect 2
function s.con2filter(c)
	return c:IsSetCard(0xf3e)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con2filter,tp,LOCATION_ONFIELD,0,nil)
	return g>0
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,LOCATION_GRAVE)
end

function s.op2xyzfilter(c)
	return c:IsXyzSummonable(nil) and c:IsSetCard(0xf3e)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
			local g=Duel.GetMatchingGroup(s.op2xyzfilter,tp,LOCATION_EXTRA,0,nil)
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.BreakEffect()
				local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
				local tc=sg:GetFirst()
				Duel.XyzSummon(tp,tc,nil)
			end
		end
	end
end
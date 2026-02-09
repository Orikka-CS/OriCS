--뮬베이릿 에스카
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c)
	return c:IsSetCard(0xf3a) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.op1filter(c,e,tp)
	return c:IsSetCard(0xf3a) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
		return #g>0 
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleDeck(tp)
		local mg=Duel.GetMatchingGroup(s.op1filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil,e,tp)
		if #mg>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local msg=aux.SelectUnselectGroup(mg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
			Duel.SpecialSummon(msg,0,tp,1-tp,false,false,POS_FACEUP)
		end
	end
end

--effect 2
function s.tg2filter(c,e)
	return c:IsSetCard(0xf3a) and not c:IsCode(id) and c:IsFaceup() and c:IsCanBeEffectTarget(e)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_REMOVED,0,nil,e)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,3,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,sg,#sg,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoGrave(tg,REASON_EFFECT+REASON_RETURN)
	end
end
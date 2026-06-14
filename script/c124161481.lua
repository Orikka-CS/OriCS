--엔비램블 이아소나
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
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
function s.tg1spfilter(c,e,tp)
	return c:IsSetCard(0xf3f) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end

function s.tg1thfilter(c)
	return c:IsSetCard(0xf3f) and c:IsSpell() and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local spg=Duel.GetMatchingGroup(s.tg1spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	local thg=Duel.GetMatchingGroup(s.tg1thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and #spg>0 and #thg>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local spg=Duel.GetMatchingGroup(s.tg1spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	local thg=Duel.GetMatchingGroup(s.tg1thfilter,tp,LOCATION_DECK,0,nil)
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and #spg>0 and #thg>0 then
		local spsg=aux.SelectUnselectGroup(spg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
		if Duel.SpecialSummon(spsg,0,tp,1-tp,false,false,POS_FACEUP)>0 then
			local thsg=aux.SelectUnselectGroup(thg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
			Duel.SendtoHand(thsg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,thsg)
			Duel.ShuffleDeck(tp)
		end
	end
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.tg2filter(c)
	return c:IsAbleToGrave()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,0,LOCATION_HAND,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,0,LOCATION_HAND,nil)
	if #g>0 then
		local sg=g:RandomSelect(tp,1)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
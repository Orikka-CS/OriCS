--란샤르드 그리프 오브
local s,id=GetID()
function s.initial_effect(c)
	--fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf2e),s.mfilter)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--fusion
function s.mfilter(c,sc,st,tp)
	return not c:IsType(TYPE_FUSION,sc,st,tp) and c:IsSetCard(0xf2e,sc,st,tp)
end

--effect 1
function s.con1filter(c,e,tp,re)
	return c:IsReason(REASON_EFFECT) and re:GetHandler()~=e:GetHandler() and not c:IsReason(REASON_DRAW) and c:IsControler(1-tp)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.con1filter,1,nil,e,tp,re)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(Card.IsAbleToGrave,tp,0,LOCATION_HAND,nil)>1 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,2)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_HAND,nil)
	if #g>1 then
		sg=g:RandomSelect(tp,2)
		Duel.ConfirmCards(tp,sg)
		local ssg=aux.SelectUnselectGroup(sg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
		Duel.SendtoGrave(ssg,REASON_EFFECT)
		Duel.ShuffleHand(1-tp)
	end
end

--effect2
function s.tg2ofilter(c)
	return c:IsSetCard(0xf2e) and c:IsMonster() and c:IsAbleToHand()
end

function s.tg2filter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsSetCard(0xf2e) and c:IsAbleToHand()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tg2filter(chkc,e,tp) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local og=Duel.GetMatchingGroup(s.tg2ofilter,tp,LOCATION_DECK,0,nil,e,tp)
	if chk==0 then return #g>0 and #og>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND):GetFirst()
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,og,1,0,LOCATION_DECK)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	local og=Duel.GetMatchingGroup(s.tg2ofilter,tp,LOCATION_DECK,0,nil)
	if #og==0 then return end
	local osg=aux.SelectUnselectGroup(og,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND):GetFirst()
	if Duel.SendtoHand(osg,1-tp,REASON_EFFECT)>0 and tg then
		 Duel.BreakEffect()
		Duel.SendtoHand(tg,tp,REASON_EFFECT)
	end
end
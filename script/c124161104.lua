--독훼귀회귀
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DAMAGE)
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
function s.con1filter(c,tp)
	return c:IsSetCard(0xf26) and c:IsControler(tp)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con1filter,nil,tp)>0
end

function s.tg1b1filter(c)
	return c:IsSetCard(0xf26) and c:IsAbleToGrave()
end

function s.tg1b2filter(c,e,tp)
	return c:IsSetCard(0xf26) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tg1b3filter(c)
	return c:IsSetCard(0xf26) and c:IsSpellTrap() and c:IsAbleToGrave()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(s.tg1b1filter,tp,LOCATION_DECK,0,nil)
	local g2=Duel.GetMatchingGroup(s.tg1b2filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local g3=Duel.GetMatchingGroup(s.tg1b3filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	local b1=#g1>0
	local b2=#g2>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b3=#g3>0 and Duel.IsPlayerCanDraw(tp,1)
	if chk==0 then return b1 or b2 or b3 end
	local b=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)},{b3,aux.Stringid(id,2)})
	e:SetLabel(b)
	if b==1 then
		e:SetCategory(CATEGORY_TOGRAVE)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	elseif b==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,LOCATION_DECK)
	end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local b=e:GetLabel()
	local g
	local sg
	if b==1 then
		g=Duel.GetMatchingGroup(s.tg1b1filter,tp,LOCATION_DECK,0,nil)
		if #g==0 then return end
		sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	elseif b==2 then
		g=Duel.GetMatchingGroup(s.tg1b2filter,tp,LOCATION_GRAVE,0,nil,e,tp)
		if #g==0 then return end
		sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	else
		g=Duel.GetMatchingGroup(s.tg1b3filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
		if #g==0 then return end
		sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
		if Duel.SendtoGrave(sg,REASON_EFFECT)>0 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

--effect 2
function s.tg2filter(c,e)
	return c:IsSetCard(0xf26) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,e:GetHandler(),e)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,5,aux.TRUE,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#sg*400)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.Damage(1-tp,ct*400,REASON_EFFECT)
	end
end
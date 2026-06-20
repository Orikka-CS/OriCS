--엔비램블 글레어
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1filter(c,tp)
	return c:IsSetCard(0xf3f) and c:IsMonster() and c:IsControler(1-tp)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con1filter,nil,tp)>0
end

function s.tg1hfilter(c)
	return c:IsAbleToGrave()
end

function s.tg1dfilter(c)
	return c:IsSetCard(0xf3f) and c:IsAbleToGrave()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local hg=Duel.GetMatchingGroup(s.tg1hfilter,tp,LOCATION_HAND,0,nil)
	local dg=Duel.GetMatchingGroup(s.tg1dfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #hg>0 or #dg>0 end
	local b1=#hg>0
	local b2=#dg>0
	local b=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	e:SetLabel(b)
	if b==1 then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local b=e:GetLabel()
	if b==1 then
		local g=Duel.GetMatchingGroup(s.tg1hfilter,tp,LOCATION_HAND,0,nil)
		if #g>0 then
			local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	else
		local g=Duel.GetMatchingGroup(s.tg1dfilter,tp,LOCATION_DECK,0,nil)
		if #g>0 then
			local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsSetCard(0xf3f) and c:IsMonster() and c:IsControler(tp)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,tp)>0
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGrave() and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 then
		Duel.BreakEffect()
		Duel.MoveToField(c,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
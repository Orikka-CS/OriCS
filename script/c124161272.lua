--메가히트 슈퍼노바
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():IsReason(REASON_EFFECT) end)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c,e,tp)
	return c:IsSetCard(0xf31) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,LOCATION_DECK)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON):GetFirst()
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		if sg:IsPreviousLocation(LOCATION_HAND) and Duel.IsPlayerCanDraw(tp,1) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

--effect 2
function s.tg2filter(c,e,tp)
	return c:IsSetCard(0xf31) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_DECK)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil,e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
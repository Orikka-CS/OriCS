--스노위퍼 바실리
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetValue(function() return 0,0x11 end)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSequence()==0 or c:GetSequence()==4
end

function s.cst2filter(c)
	return c:IsSetCard(0xf35) and not c:IsPublic()
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_HAND,0,c)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONFIRM)
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(tp)
end

function s.tg2filter(c,e,tp,zone)
	return c:IsSetCard(0xf35) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone
	if e:GetHandler():GetSequence()==0 then
		zone=0x10
	else
		zone=0x1
	end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil,e,tp,zone)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_DECK)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local zone
	if e:GetHandler():GetSequence()==0 then
		zone=0x10
	else
		zone=0x1
	end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil,e,tp,zone)
	if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then  
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON):GetFirst()
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
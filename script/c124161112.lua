--캘라피스 그란
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_HAND+LOCATION_REMOVED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable(REASON_COST) end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end

function s.tg1filter(c,e,tp)
	return c:IsSetCard(0xf27) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tg1rfilter(c)
	return c:IsSetCard(0xf27) and c:IsAbleToRemove()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil,e,tp)
	local rg=Duel.GetMatchingGroup(s.tg1rfilter,tp,LOCATION_HAND,0,c)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 and #rg>0
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_DECK)
end

function s.op1filter(c)
	return c:IsSetCard(0xf27) and c:IsSpellTrap() and c:IsSSetable() and c:IsFaceup()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil,e,tp)
	local rg=Duel.GetMatchingGroup(s.tg1rfilter,tp,LOCATION_HAND,0,c)
	if #rg==0 then return end
	local rsg=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE)
	Duel.Remove(rsg,POS_FACEUP,REASON_EFFECT)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		local tg=Duel.GetMatchingGroup(s.op1filter,tp,LOCATION_REMOVED,0,nil)
		if #tg>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			local tsg=aux.SelectUnselectGroup(tg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SET)
			Duel.SSet(tp,tsg) 
		end
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0xf27)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg and not eg:IsContains(e:GetHandler()) and eg:IsExists(s.con2filter,1,nil,tp)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		if c:IsSummonLocation(LOCATION_REMOVED) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_TYPE)
			e1:SetValue(TYPE_TUNER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
			c:RegisterEffect(e1)
		end
	end
	local b1=true
	local b2=c:IsLevelAbove(2)
	local b3=c:IsLevelAbove(3)
	local b=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)},{b3,aux.Stringid(id,2)}) 
	if b==1 then return end
	local val
	if b==2 then val=-1 else val=-2 end
	Duel.BreakEffect()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetValue(val)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e2)
end
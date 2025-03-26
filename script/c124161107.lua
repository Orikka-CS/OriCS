--캘라피스 라임스
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetValue(s.val1)
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
function s.tg1filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xf27) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.tg1filter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,3))
end

function s.val1(e,c)
	return s.tg1filter(c,e:GetHandlerPlayer())
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
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
--백연초의 정원-니코티아나
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(_,c) return c:IsSetCard(0xf2b) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_PAY_LPCOST)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con2)
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET) 
	e3:SetTargetRange(1,0)
	e3:SetCondition(s.con3)
	c:RegisterEffect(e3)
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD)
	e3a:SetCode(EFFECT_CHANGE_DAMAGE)
	e3a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3a:SetRange(LOCATION_FZONE)
	e3a:SetTargetRange(1,0)
	e3a:SetCondition(s.con3)
	e3a:SetValue(s.val3)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e3b)
end

--effect 1
function s.val1(e,c)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),124161180)*300
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and re and re:IsActivated() and re:GetHandler():IsSetCard(0xf2b) and not re:GetHandler():IsType(TYPE_FIELD)
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,300) end
	Duel.PayLPCost(tp,300)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,124161168,0xf2b,TYPES_TOKEN,300,300,1,RACE_PLANT,ATTRIBUTE_FIRE) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,124161168,0xf2b,TYPES_TOKEN,300,300,1,RACE_PLANT,ATTRIBUTE_FIRE) then return end
	local token=Duel.CreateToken(tp,124161168)
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end

--effect 3
function s.con3filter(c)
	return c:IsSetCard(0xf2b) and c:IsType(TYPE_FUSION) and c:IsFaceup()
end

function s.con3(e)
	local g=Duel.GetMatchingGroupCount(s.con3filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	return g>0
end

function s.val3(e,re,val,r,rp,rc)
	if (r&REASON_EFFECT)~=0 then return 0 end
	return val
end
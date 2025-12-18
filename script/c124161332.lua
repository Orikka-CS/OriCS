--스노위퍼 밴티지
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
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf35) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(s.tg3)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end

--effect 1
function s.val1filter(c)
	return c:GetSequence()==0 or c:GetSequence()==4
end

function s.val1(e,c)
	return Duel.GetMatchingGroupCount(s.val1filter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*300
end

--effect 2
function s.con2filter(c)
	return c:IsSetCard(0xf35) and not c:IsType(TYPE_FIELD) and c:IsFaceup()
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con2filter,tp,LOCATION_ONFIELD,0,nil)
	return g>0
end

function s.tg2filter(c)
	local tp=c:GetControler()
	return c:GetSequence()<5 and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>0
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tg2filter(chkc) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.tg2filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	Duel.SelectTarget(tp,s.tg2filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local ttp=tc:GetControler()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or Duel.GetLocationCount(ttp,LOCATION_MZONE,ttp,LOCATION_REASON_CONTROL)<=0 then return end
	local p1,p2,i
	if tc:IsControler(tp) then
		i=0
		p1=LOCATION_MZONE
		p2=0
	else
		i=16
		p2=LOCATION_MZONE
		p1=0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,p1,p2,0),2)-i)
end

--effect 3
function s.tg3(e,c)
	return c:IsFaceup() and c:IsSetCard(0xf35) and (c:GetSequence()==0 or c:GetSequence()==4)
end
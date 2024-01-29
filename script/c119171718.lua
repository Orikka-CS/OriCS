--백발의 노인
local s,id=GetID()
function s.initial_effect(c)
	--battle indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--effect indestructable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.ifilter)
	c:RegisterEffect(e2)
	--change name
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetValue(id)
	c:RegisterEffect(e3)
	--change setname
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(s.efilter)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsCode,id))
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
	if EFFECT_CHANGE_SETCODE then
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetCode(EFFECT_CHANGE_SETCODE)
		e6:SetRange(LOCATION_MZONE)
		e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e6:SetTarget(aux.TargetBoolFunction(Card.IsCode,id))
		e6:SetValue(0)
		c:RegisterEffect(e6)
	end
end
s.listed_names={id}
function s.ifilter(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER) and
		((re:IsHasType(EFFECT_TYPE_ACTIONS) and re:GetActivateLocation()==LOCATION_MZONE)
			or re:GetHandler():IsLocation(LOCATION_MZONE))
end
function s.efilter(e,re)
	local et=re:GetCode()
	return et==EFFECT_ADD_SETCODE or (EFFECT_CHANGE_SETCODE and et==EFFECT_CHANGE_SETCODE and re:GetValue()~=0)
end

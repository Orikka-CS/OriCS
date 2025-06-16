--절해의 디바인 드래곤 리비아탄
local s,id=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),10,3)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SET_ATTACK_FINAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.tar4)
	e4:SetValue(s.val4)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e5:SetValue(s.val5)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id)
	e6:SetTarget(s.tar6)
	e6:SetOperation(s.op6)
	c:RegisterEffect(e6)
end
function s.val1(e,te)
	local tc=te:GetHandler()
	return te:GetOwner()~=e:GetOwner() and tc:IsAttribute(ATTRIBUTE_WATER) and te:IsActiveType(TYPE_MONSTER)
end
function s.val2(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
function s.val3(e,re)
	local rc=re:GetHandler()
	return rc:IsAttribute(ATTRIBUTE_WATER) and re:IsActiveType(TYPE_MONSTER)
end
function s.tar4(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
function s.val4(e,c)
	return c:GetAttack()*2
end
function s.val5(e,c)
	return c:GetDefense()*2
end
function s.tfil6(c,e,tp,xc)
	return c:IsAttribute(ATTRIBUTE_WATER) and not c:IsType(TYPE_TOKEN)
		and c:IsCanBeXyzMaterial(xc,tp,REASON_EFFECT)
end
function s.tar6(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsType(TYPE_XYZ)
			and Duel.IsExistingMatchingCard(s.tfil6,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,c)
	end
end
function s.op6(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tfil6),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,
		nil,e,tp,c):GetFirst()
	if tc and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(c,tc,true)
	end
end
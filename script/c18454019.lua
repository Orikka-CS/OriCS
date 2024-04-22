--마과학백조 블랑
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"S","M")
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S","M")
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"F","S")
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetTR("M",0)
	e4:SetValue(1600)
	e4:SetCondition(s.con4)
	e4:SetTarget(s.tar4)
	c:RegisterEffect(e4)
end
function s.vfil1(c,tp)
	return c:IsControler(tp) and c:IsSetCard("마과학") and c:GetType()&(TYPE_SPELL+TYPE_CONTINUOUS)==(TYPE_SPELL+TYPE_CONTINUOUS)
end
function s.vval1(c)
	local tatk=c:GetTextAttack()
	if tatk>0 then
		return tatk
	end
	return 0
end
function s.val1(e)
	local tp=e:GetHandlerPlayer()
	local c=e:GetHandler()
	local g=c:GetColumnGroup():Filter(s.vfil1,nil,tp)
	local sum=g:GetSum(s.vval1)
	return sum
end
function s.con4(e)
	local c=e:GetHandler()
	return c:GetType()&(TYPE_SPELL+TYPE_CONTINUOUS)==(TYPE_SPELL+TYPE_CONTINUOUS)
end
function s.tar4(e,c)
	local h=e:GetHandler()
	local g=h:GetColumnGroup()
	return g:IsContains(c) and c:IsSetCard("마과학")
end
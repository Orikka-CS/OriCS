--볼틱갭츠 쿠랑 앙페르
local s,id=GetID()
function s.initial_effect(c)
	--link
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf37),2)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(s.con2)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e2a=e2:Clone()
	e2a:SetCode(EFFECT_PIERCE)
	e2a:SetValue(DOUBLE_DAMAGE)
	c:RegisterEffect(e2a)
end

--effect 1
function s.tg1filter(c)
	return c:IsFaceup() and c:IsLinked()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return false end
	local _,max=g:GetMaxGroup(Card.GetAttack)
	local _,min=g:GetMinGroup(Card.GetAttack)
	local diff=max-min
	if chk==0 then return diff>0 end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,diff)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if c:IsRelateToEffect(e) and c:IsFaceup() and #g>0 then
		local _,max=g:GetMaxGroup(Card.GetAttack)
		local _,min=g:GetMinGroup(Card.GetAttack)
		local diff=max-min
		if diff>0 then
			c:UpdateAttack(diff,nil,c)
		end
	end
end

--effect 2
function s.con2filter(c)
	return c:IsFaceup() and c:IsLinked()
end

function s.con2(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.con2filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return false end
	local _,max=g:GetMaxGroup(Card.GetAttack)
	local _,min=g:GetMinGroup(Card.GetAttack)
	return (max-min)>=c:GetBaseAttack()
end
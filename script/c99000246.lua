--데스펙터 프라임
local s,id=GetID()
function s.initial_effect(c)
	--order summon
	aux.AddOrderProcedure(c,"R",nil,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),aux.NOT(aux.FilterBoolFunctionEx(Card.IsType,TYPE_TOKEN)),s.ordfil1)
	c:EnableReviveLimit()
	--Lord Godfrey
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonLocation(LOCATION_EXTRA) end)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--자신 묘지에 "스펙터 프라임" 몬스터가 존재할 경우, 이 카드는 상대 효과의 대상이 되지 않는다.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.indcon)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
function s.ordfil1(c)
	return c:IsSummonLocation(LOCATION_DECK|LOCATION_EXTRA) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dg=Group.CreateGroup()
	local chk=true
	while chk do
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,c)
		local tc=g:GetFirst()
		while tc do
			local preatk=tc:GetAttack()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-2000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			if preatk~=0 and tc:IsAttack(0) then
				Duel.HintSelection(tc)
				dg:AddCard(tc)
			end
			tc=g:GetNext()
		end
		if Duel.Destroy(dg,REASON_EFFECT)~=0 then
			chk=true
		else
			chk=false
		end
	end
end
function s.cfilter(c)
	return c:IsSetCard(0xc18)
end
function s.indcon(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
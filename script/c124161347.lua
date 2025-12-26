--다운폴루스턴 애시데인
local s,id=GetID()
function s.initial_effect(c)
	--synchro
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf36),1,1,Synchro.NonTunerEx(Card.IsType,TYPE_SYNCHRO),1,99)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_LVCHANGE+CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.con2)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
end

--effect 1
function s.con1filter(c)
	return c:IsSetCard(0xf36) and c:IsFaceup()
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_ONFIELD,0,e:GetHandler())
	return g>0
end

function s.tg1filter(c)
	return c:IsFaceup() and c:IsNegatable() and c:IsAbleToRemove()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroupCount(s.tg1filter,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return g>0 and c:GetLevel()>0 end
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
	if c:GetOriginalLevel()-c:GetLevel()>=3 then
		Duel.SetChainLimit(function(e,ep,tp) return ep==tp end)
	end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsLevelAbove(2) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 then
			local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_NEGATE):GetFirst()
			sg:NegateEffects(c)
			Duel.AdjustInstantly(sg)
			if sg:IsDisabled() then
				Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end

--effect 2
function s.con2(e)
	local c=e:GetHandler()
	return c:GetLevel()<c:GetOriginalLevel()
end

function s.val2(e,c)
	local hc=e:GetHandler()
	return (hc:GetOriginalLevel()-hc:GetLevel())*-1
end

--effect 3
function s.val3(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE and not rc:IsLevelAbove(2)
end
--충격과 공포의 붉은 실
local s,id=GetID()
function s.initial_effect(c)
	local e2=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0xc00))
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCost(s.cost1)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetValue(function(e,c) e:SetLabel(1) end)
	e3:SetCondition(function(e)
		local tp=e:GetHandlerPlayer()
		return Duel.CheckLPCost(tp,1000)
	end)
	c:RegisterEffect(e3)
	e1:SetLabelObject(e3)
	e2:SetLabelObject(e3)
end
s.listed_series={0xc00}
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:GetLabelObject():SetLabel(0)
		return true
	end
	if e:GetLabelObject():GetLabel()>0 then
		e:GetLabelObject():SetLabel(0)
		Duel.PayLPCost(tp,1000)
	end
end
function s.tfil1(c)
	return c:IsFaceup() and c:IsSetCard(0xc00)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsOnField() and chkc:IsControler(tp) and s.tfil1(chkc) and chkc~=c
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tfil1,tp,LOCATION_ONFIELD,0,1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tfil1,tp,LOCATION_ONFIELD,0,1,1,c)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetRange(LOCATION_ONFIELD)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_IMMEDIATELY_APPLY)
		e1:SetDescription(3110)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(s.oval11)
		e1:SetOwnerPlayer(tp)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		tc:RegisterEffect(e2)
	end
end
function s.oval11(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end

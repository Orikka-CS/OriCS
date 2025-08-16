--G.Rock 세트
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.pfil1,nil,2,nil,nil,nil,nil,false,s.pfun1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_TO_GRAVE)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.tar3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end
function s.pfil1(c,xc,st,p)
	return c:IsXyzLevel(xc,9) or c:IsRank(9)
end
function s.pfun1(g,tp,xc)
	return g:FilterCount(Card.IsXyzLevel,nil,xc,9)==#g or g:FilterCount(Card.IsRank,nil,9)==#g
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup()
	end
	if chk==0 then
		return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DOUBLE_XYZ_MATERIAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		e1:SetOperation(function(e,c)
			return c:IsRank(9)
		end)
		tc:RegisterEffect(e1)
	end
end
function s.tfil3(c,chk)
	return c:IsSetCard(0xfa6) and (c:IsAbleToGrave() or chk)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil3,tp,LOCATION_DECK,0,1,nil,c:IsType(TYPE_XYZ))
			and Duel.IsExistingMatchingCard(s.tfil3,tp,LOCATION_EXTRA,0,1,nil,c:IsType(TYPE_XYZ))
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,s.tfil3,tp,LOCATION_DECK,0,1,1,nil,c:IsRelateToEffect(e))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=Duel.SelectMatchingCard(tp,s.tfil3,tp,LOCATION_EXTRA,0,1,1,nil,c:IsRelateToEffect(e))
	g1:Merge(g2)
	local tc=g1:GetFirst()
	while tc do
		Duel.Hint(HINT_CARD,0,tc:GetOriginalCode())
		local b1=tc:IsAbleToGrave()
		local b2=c:IsRelateToEffect(e)
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,0)},
			{b2,aux.Stringid(id,1)})
		if op==1 then
			Duel.SendtoGrave(tc,REASON_EFFECT)
		elseif op==2 then
			Duel.Overlay(c,tc,true)
		end
		tc=g1:GetNext()
	end
end
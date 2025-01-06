--검은 실×정의
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,1,2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
function s.tfil11(c,tp)
	return c:IsSetCard(0xc05) and c:IsAbleToHand()
		and not Duel.IsExistingMatchingCard(s.tfil13,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function s.tfil12(c)
	return c:IsSetCard(0xc05) and c:IsAbleToHand() and c:IsFaceup() and not c:IsCode(id)
end
function s.tfil13(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local b1=Duel.IsExistingMatchingCard(s.tfil11,tp,LOCATION_DECK,0,1,nil,tp)
	local b2=Duel.IsExistingTarget(s.tfil12,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and s.tfil12(chkc)
	end
	if chk==0 then
		return b1 or b2
	end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	if op==1 then
		e:SetProperty(0)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetCategory(CATEGORY_TOHAND)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g=Duel.SelectTarget(tp,s.tfil12,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.tfil11,tp,LOCATION_DECK,0,1,1,nil,tp)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==2 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and (rc:IsType(TYPE_XYZ) or rc:IsSetCard(0xc05))
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsPlayerCanDraw(tp,1)
	local b2=true
	if chk==0 then
		return b1 or b2
	end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	elseif op==2 then
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		Duel.Draw(tp,1,REASON_EFFECT)
	elseif op==2 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(2)
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,1)
		Duel.RegisterEffect(e1,tp)
	end
end
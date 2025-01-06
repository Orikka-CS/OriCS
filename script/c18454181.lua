--검은 실×여왕
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,8,2,s.pfil1,aux.Stringid(id,0),2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
function s.pfil1(c,tp,xyzc)
	return c:IsFaceup() and c:IsSetCard(0xc05,xyzc,SUMMON_TYPE_XYZ,tp) and not c:IsSummonCode(xyzc,SUMMON_TYPE_XYZ,tp,id)
		and Duel.GetCurrentPhase()&(PHASE_MAIN1+PHASE_MAIN2)~=0 and not Duel.CheckPhaseActivity()
end
function s.tfil11(c,e,tp)
	return c:IsSetCard(0xc05)and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not Duel.IsExistingMatchingCard(s.tfil13,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function s.tfil12(c,e,tp)
	return (c:IsSetCard(0xc05) or (c:IsType(TYPE_XYZ) and c:IsRankBelow(7)))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.tfil13(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local b1=Duel.IsExistingMatchingCard(s.tfil11,tp,LOCATION_DECK,0,1,nil,e,tp)
	local b2=Duel.IsExistingTarget(s.tfil12,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tfil12(chkc,e,tp)
	end
	if chk==0 then
		return (b1 or b2) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,s.tfil12,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.tfil11,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and (rc:IsType(TYPE_XYZ) or rc:IsSetCard(0xc05))
end
function s.tfil2(c)
	return c:IsSetCard(0xc05) and c:IsAbleToHand() and not c:IsCode(id) and c:IsFaceup()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local op=e:GetLabel()
		if op==1 then
			return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(tp) and s.tfil2(chkc)
		elseif op==2 then
			return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove()
		end
		return false
	end
	local b1=Duel.IsExistingTarget(s.tfil2,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
	local b2=Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
	if chk==0 then
		return b1 or b2
	end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,3)},
		{b2,aux.Stringid(id,4)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g=Duel.SelectTarget(tp,s.tfil2,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_REMOVE)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then
		return
	end
	local op=e:GetLabel()
	if op==1 then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	elseif op==2 then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
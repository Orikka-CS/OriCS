--엉킨 실∞밤하늘을 담는 그릇
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(aux.exccon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.tar3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end
function s.val1(e)
	local te=e:GetLabelObject()
	te:SetLabel(1)
end
function s.cfil2(c)
	return ((c:IsLocation(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_ONFIELD) and c:IsAbleToGraveAsCost())
		or (c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemoveAsCost())) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_EFFECT)
end
function s.cfun2(sg,e,tp,mg)
	return sg:IsExists(Card.IsRace,1,nil,s.race) and sg:IsExists(Card.IsAttribute,1,nil,s.attribute)
end
function s.tfil2(c,label,g)
	s.race=c:GetRace()
	s.attribute=c:GetAttribute()
	local res=c:IsCanTurnSet() and (label~=1 or aux.SelectUnselectGroup(g,e,tp,1,2,s.cfun2,0))
	s.race=nil
	s.attribute=nil
	return res
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local label=e:GetLabel()
	e:SetLabel(0)
	local g=Duel.GetMatchingGroup(s.cfil2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,nil)
	if chkc then
		return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanTurnSet()
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tfil2,tp,0,LOCATION_MZONE,1,nil,label,g)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sg=Duel.SelectTarget(tp,s.tfil2,tp,0,LOCATION_MZONE,1,1,nil,label,g)
	if label==1 then
		local tc=sg:GetFirst()
		s.race=tc:GetRace()
		s.attribute=tc:GetAttribute()
		local tg=aux.SelectUnselectGroup(g,e,tp,1,2,s.cfun2,1,tp,HINTMSG_TOGRAVE)
		s.race=nil
		s.attribute=nil
		local rg=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		tg:Sub(rg)
		Duel.SendtoGrave(tg,REASON_COST)
		Duel.Remove(rg,POS_FACEUP,REASON_COST)
	end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		return
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.oval21)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.otar22)
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_MSET)
	Duel.RegisterEffect(e3,tp)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e4,tp)
end
function s.oval21(e,te)
	return te:IsActiveType(TYPE_MONSTER)
end
function s.otar22(e,c)
	return c:IsType(TYPE_EFFECT)
end
function s.tfil3(c)
	return c:IsFaceup() and c:IsSSetable() and c:IsSetCard(0xc06) and not c:IsCode(id)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.tfil3(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tfil3,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,s.tfil3,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	if tc:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SSet(tp,tc)
	end
end
--엉킨 실∞악마조차 빼앗아 입은 여신
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetCondition(aux.exccon)
	e3:SetCost(aux.bfgcost)
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
	local res=c:IsFaceup() and c:GetAttack()~=0 and (label~=1 or aux.SelectUnselectGroup(g,e,tp,1,2,s.cfun2,0))
	s.race=nil
	s.attribute=nil
	return res
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local label=e:GetLabel()
	e:SetLabel(0)
	local g=Duel.GetMatchingGroup(s.cfil2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,nil)
	if chkc then
		return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup()
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tfil2,tp,0,LOCATION_MZONE,1,nil,label,g)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
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
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
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
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.otar31)
	e1:SetValue(s.oval31)
	Duel.RegisterEffect(e1,tp)
end
function s.otar31(e,c)
	return not c:IsType(TYPE_EFFECT)
end
function s.oval31(e,c)
	return c:GetBaseAttack()
end
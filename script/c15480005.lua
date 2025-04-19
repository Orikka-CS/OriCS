--오성신 강림
local s,id=GetID()
function s.initial_effect(c)
	Ritual.AddProcGreater({handler=c,filter=s.tfil11,lv=Card.GetAttack,matfilter=s.tfil12,
		location=LOCATION_HAND+LOCATION_GRAVE,requirementfunc=Card.GetAttack})
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
function s.tfil11(c)
	return c:GetAttack()>0 and c:GetType()&(TYPE_RITUAL+TYPE_MONSTER)==(TYPE_RITUAL+TYPE_MONSTER) and c:IsCode(15480009)
end
function s.tfil12(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:GetAttack()>0
end
function s.tfil2(c)
	return c:IsFaceup() and c:IsSetCard(0xffe) and c:GetAttack()>=1000
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tfil2(chkc)
	end
	if chk==0 then
		return c:IsAbleToHand() and Duel.IsExistingTarget(s.tfil2,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tfil2,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup()
		and tc:UpdateAttack(-1000,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,c)==-1000
		and c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end

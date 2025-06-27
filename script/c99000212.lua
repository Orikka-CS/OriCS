--æ∆∏Æ ∂Û≥Õ≈ß∑ØΩ∫
local m=99000212
local cm=_G["c"..m]
function cm.initial_effect(c)
	aux.AddCodeList(c,99000218)
	--change code
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetValue(99000218)
	c:RegisterEffect(e0)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,m)
	e1:SetTarget(cm.sptg)
	e1:SetOperation(cm.spop)
	c:RegisterEffect(e1)
	--extra summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,m+1000)
	e2:SetCost(cm.sumcost)
	e2:SetTarget(cm.sumtg)
	e2:SetOperation(cm.sumop)
	c:RegisterEffect(e2)
end
cm.card_code_list={99000218}
function cm.thfilter1(c,tp,code)
	return c:IsFaceup() and aux.IsCodeListed(c,99000218) and c:GetOriginalCode()~=code
		and c:IsAbleToHand() and Duel.GetMZoneCount(tp,c)
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local code=e:GetHandler():GetOriginalCode()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and cm.thfilter1(chkc,tp,code) end
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and Duel.IsExistingTarget(cm.thfilter1,tp,LOCATION_ONFIELD,0,1,nil,tp,code) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,cm.thfilter1,tp,LOCATION_ONFIELD,0,1,1,nil,tp,code)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function cm.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function cm.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) end
end
function cm.sumop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(m,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetTarget(cm.extg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function cm.extg(e,c)
	return aux.IsCodeListed(c,99000218)
end
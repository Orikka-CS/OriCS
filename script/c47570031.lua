--블렌디아 압생트

local m=47570031
local cm=_G["c"..m]

function cm.initial_effect(c)

    --special_summon_and_equip
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
    e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_HAND)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,m)
	e0:SetTarget(cm.eqtg)
	e0:SetOperation(cm.eqop)
	c:RegisterEffect(e0)

	
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,m)
	e1:SetCondition(cm.eqcon2)
	e1:SetTarget(cm.eqtg2)
	e1:SetOperation(cm.eqop2)
	c:RegisterEffect(e1)
end

function cm.eqfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xccd)
end

function cm.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and cm.eqfilter(chkc) end

	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(cm.eqfilter,tp,LOCATION_GRAVE,0,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local sg=Duel.SelectTarget(tp,cm.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,sg,1,0,0)
end

function cm.eqlimit(e,c)
	return e:GetOwner()==c and not c:IsDisabled()
end

function cm.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if c:IsRelateToEffect(e) and tc and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		if not Duel.Equip(tp,tc,c) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(cm.eqlimit)
		tc:RegisterEffect(e1)
	end
end



function cm.eqcon2(e,tp,eg,ep,ev,re,r,rp)
        return e:GetHandler():IsPreviousLocation(LOCATION_MZONE+LOCATION_HAND)
end

function cm.eqfilter2(c)
        return c:IsFaceup() and c:IsSetCard(0xccd)
end
function cm.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
        if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cm.eqfilter2(chkc) end
        if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
                and Duel.IsExistingTarget(cm.eqfilter2,tp,LOCATION_MZONE,0,1,nil) end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        Duel.SelectTarget(tp,cm.eqfilter2,tp,LOCATION_MZONE,0,1,1,nil)
        Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
        Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end

function cm.eqop2(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        local tc=Duel.GetFirstTarget()
        if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and tc:IsRelateToEffect(e) then
                if not Duel.Equip(tp,c,tc) then return end
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_EQUIP_LIMIT)
                e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetLabelObject(tc)
                e1:SetValue(cm.eqlimit2)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                c:RegisterEffect(e1)
        end
end

function cm.eqlimit2(e,c)
        return c==e:GetLabelObject()
end
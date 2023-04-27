--전기양-38(서른여덟)

local m=47250038
local cm=_G["c"..m]

function cm.initial_effect(c)

	--module summon
	c:EnableReviveLimit()
	aux.AddModuleProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_MODULE),nil,2,10,cm.lcheck)

	--splimit
	local e99=Effect.CreateEffect(c)
	e99:SetType(EFFECT_TYPE_SINGLE)
	e99:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e99:SetCode(EFFECT_SPSUMMON_CONDITION)
	e99:SetRange(LOCATION_EXTRA)
	e99:SetValue(cm.splimit)
	c:RegisterEffect(e99)


	--Effect_01
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_SSET+TIMING_EQUIP+TIMING_END_PHASE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(cm.eqtg)
	e1:SetOperation(cm.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,cm.eqval,Card.EquipByEffectAndLimitRegister,e1)

	--Effect_02
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetCondition(cm.discon)
	e5:SetOperation(cm.disop)
	e5:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e5)

	--Effect_03
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(cm.spcon)
	e3:SetTarget(cm.sptg)
	e3:SetOperation(cm.spop)
	c:RegisterEffect(e3)
	
end

function cm.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_MODULE)==SUMMON_TYPE_MODULE
end

function cm.lcheck(g,lc)
	return g:IsExists(Card.IsSetCard,1,nil,0xe2e)
end

function cm.eqfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and ((c:IsLocation(LOCATION_MZONE) and c:IsAbleToChangeControler()) or c:IsLocation(LOCATION_GRAVE))
end

function cm.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and cm.eqfilter(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(cm.eqfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,cm.eqfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,c,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end


function cm.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsMonster() and not tc:IsForbidden() then
		e:GetHandler():EquipByEffectAndLimitRegister(e,tp,tc)
		tc:RegisterFlagEffect(m,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end

function cm.eqval(ec,c,tp)
	return true
end

function cm.discon(e,tp,eg,ep,ev,re,r,rp)

	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end

	local g=e:GetHandler():GetEquipGroup()

	return re:IsActiveType(TYPE_MONSTER) and g:IsExists(Card.IsCode,1,nil,re:GetHandler():GetCode()) and rp==1-tp

end
function cm.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end



function cm.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_MODULE)
end
function cm.spfilter(c,e,tp)
	return c:IsSetCard(0xe2e) and c:IsType(TYPE_MODULE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(m)
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cm.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(cm.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,cm.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

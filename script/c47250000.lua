--전기양-00(영)

local m=47250000
local cm=_G["c"..m]

function cm.initial_effect(c)
	
	--pendulum summon
	Pendulum.AddProcedure(c)

	--P_Effect_01
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_FIELD)
	e11:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e11:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e11:SetRange(LOCATION_PZONE)
	e11:SetTargetRange(1,0)
	e11:SetTarget(cm.splimit)
	c:RegisterEffect(e11)

	--P_Effect_02
	local e12=Effect.CreateEffect(c)
	e12:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e12:SetType(EFFECT_TYPE_IGNITION)
	e12:SetRange(LOCATION_PZONE)
	e12:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e12:SetCountLimit(1,m)
	e12:SetTarget(cm.sptg1)
	e12:SetOperation(cm.spop1)
	c:RegisterEffect(e12)

	--M_Effect_01
	local e21=Effect.CreateEffect(c)
	e21:SetDescription(aux.Stringid(m,0))
	e21:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON)
	e21:SetType(EFFECT_TYPE_QUICK_O)
	e21:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e21:SetCode(EVENT_FREE_CHAIN)
	e21:SetRange(LOCATION_HAND)
	e21:SetHintTiming(TIMING_DAMAGE_STEP)
	e21:SetCountLimit(1,m+1000)
	e21:SetCondition(cm.atkcon)
	e21:SetTarget(cm.atktg)
	e21:SetOperation(cm.atkop1)
	c:RegisterEffect(e21)
	
end

function cm.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xe2e) and (sumtp&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end

function cm.filter1(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function cm.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and cm.filter1(chkc,e,tp) end

	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(cm.filter1,tp,LOCATION_SZONE,0,1,nil,e,tp) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,cm.filter1,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function cm.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

function cm.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function cm.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe2e)
end
function cm.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)

	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and cm.atkfilter(chkc) end

	if chk==0 then return Duel.IsExistingTarget(cm.atkfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)

	Duel.SelectTarget(tp,cm.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,LOCATION_HAND)
end

function cm.atkop1(e,tp,eg,ep,ev,re,r,rp,chk)

	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)

		Duel.BreakEffect()

		if c:IsLocation(LOCATION_HAND) then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
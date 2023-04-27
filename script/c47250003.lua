--전기양-03(셋)
local m=47250003
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
	e12:SetCategory(CATEGORY_EQUIP+CATEGORY_TOHAND)
	e12:SetType(EFFECT_TYPE_IGNITION)
	e12:SetRange(LOCATION_PZONE)
	e12:SetCode(EVENT_FREE_CHAIN)
	e12:SetCountLimit(1)
	e12:SetCondition(cm.eqcon)
	e12:SetTarget(cm.eqtg)
	e12:SetOperation(cm.eqop)
	c:RegisterEffect(e12)


	--M_Effect_01
	local e21=Effect.CreateEffect(c)
	e21:SetDescription(aux.Stringid(m,0))
	e21:SetCategory(CATEGORY_EQUIP)
	e21:SetType(EFFECT_TYPE_QUICK_O)
	e21:SetRange(LOCATION_HAND)
	e21:SetCode(EVENT_FREE_CHAIN)
	e21:SetCountLimit(1,m)
	e21:SetTarget(cm.eqtg2)
	e21:SetOperation(cm.eqop2)
	c:RegisterEffect(e21)

end

cm.listed_series={0xe2e}
cm.listed_names={id}

function cm.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xe2e) and (sumtp&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end


function cm.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_PZONE) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end

function cm.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe2e)
end

function cm.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cm.eqfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cm.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,cm.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function cm.eqlimit(e,c)
	return c==e:GetLabelObject()
end

function cm.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_PZONE) then
		if not Duel.SendtoHand(c,nil,REASON_EFFECT) then return end
	end

	if c:IsLocation(LOCATION_HAND) and tc:IsFaceup() and tc:IsControler(tp) and tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		if not Duel.Equip(tp,c,tc) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(cm.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end



function cm.eqfilter2(c)
	return c:IsFaceup()
end

function cm.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cm.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(cm.eqfilter2,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,cm.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function cm.eqop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_HAND) and tc:IsFaceup() and tc:IsControler(tp) and tc:IsRelateToEffect(e) then
		if not Duel.Equip(tp,c,tc) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(cm.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end

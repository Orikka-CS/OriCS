--전기양-99(아흔아홉)

local m=47250099
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
	e12:SetCategory(CATEGORY_EQUIP)
	e12:SetType(EFFECT_TYPE_IGNITION)
	e12:SetRange(LOCATION_PZONE)
	e12:SetCountLimit(1,m+1000)
	e12:SetTarget(cm.eqtg2)
	e12:SetOperation(cm.eqop2)
	c:RegisterEffect(e12)

	--M_SPSUMMON
	c:EnableReviveLimit()

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_EXTRA)
	e1:SetCondition(cm.spcon)
	e1:SetTarget(cm.sptg)
	e1:SetOperation(cm.spop)
	c:RegisterEffect(e1)
	
	--M_Effect_01
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_SPSUMMON,TIMING_BATTLE_START)
	e2:SetCondition(cm.condition)
	e2:SetCost(aux.AND(aux.dxmcostgen(1,1,nil),cm.opccost))
	e2:SetTarget(cm.thtg)
	e2:SetOperation(cm.thop)
	c:RegisterEffect(e2)

end

function cm.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xe2e) and (sumtp&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end

function cm.cfilter(c)
	if c:IsType(TYPE_MODULE) then return true
	elseif c:IsSetCard(0xe2e) then return true
	else return false end
end

function cm.filter2(c)
	return c:IsSetCard(0xe2e) and c:IsType(TYPE_MONSTER) and not c:IsForbidden() and not c:IsCode(m) and (c:IsLocation(LOCATION_DECK) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()))
end
function cm.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)

	local c=e:GetHandler()

	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and cm.cfilter(chkc) end

	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(cm.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(cm.filter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cm.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
end

function cm.eqop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if not tc:IsFaceup() or not tc:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local sg=Duel.SelectMatchingCard(tp,cm.filter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	local sc=sg:GetFirst()
	if sc then
		if not Duel.Equip(tp,sc,tc) then return end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(cm.eqlimit)
		e1:SetLabelObject(tc)
		sc:RegisterEffect(e1)
	end
end

function cm.eqlimit(e,c)
	return c==e:GetLabelObject()
end



function cm.spfilter(c,ft,tp)
	return c:IsSetCard(0xe2e) and c:IsType(TYPE_MODULE) and c:GetEquipCount()>2
end
function cm.spcon(e,c,tp)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),cm.spfilter,1,false,1,true,c,c:GetControler(),nil,false,nil) and Duel.GetLocationCountFromEx(tp,tp,e:GetHandler())>0
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,cm.spfilter,1,1,false,true,true,c,nil,nil,false,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end




function cm.opccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(m)==0 end
	c:RegisterFlagEffect(m,RESET_CHAIN,0,1)
end

function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()) or
		   (not Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase())
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
	Duel.SetChainLimit(cm.chlimit)
end
function cm.chlimit(e,ep,tp)
	return tp==ep
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SendtoHand(g,nil,REASON_EFFECT)

	-- halve battle damage
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(cm.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(m,0),nil)
end

function cm.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end

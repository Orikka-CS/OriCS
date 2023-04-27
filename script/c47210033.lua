--마이오소티스 애쉬블룸
local m=47210033
local cm=_G["c"..m]

function cm.initial_effect(c)
	
	--Link summon method
	c:EnableReviveLimit()
	Link.AddProcedure(c,cm.matfilter,2,3)

	--Effect_01
	c:SetUniqueOnField(1,0,m)
	
	--Effect_02
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cm.eff02_con)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(-1600)
	c:RegisterEffect(e2)
	local e22=e2:Clone()
	e22:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e22)

	--Effect_03
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCountLimit(1)
	e3:SetCost(cm.eff03_cost)
	e3:SetCondition(cm.eff03_con)
	e3:SetTarget(cm.eff03_tar)
	e3:SetOperation(cm.eff03_op)
	c:RegisterEffect(e3)

end

function cm.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0xa7b,lc,sumtype,tp)
end

function cm.eff02_filter(c)
	return c:IsSetCard(0xa7b)
end

function cm.eff02_con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(cm.eff02_filter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)>=3
end



function cm.eff03_filter(c)
	return c:IsSetCard(0xa7b) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_ONFIELD) and c:IsFaceup()))
end

function cm.eff03_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.eff03_filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cm.eff03_filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function cm.eff03_con(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and Duel.IsChainNegatable(ev)
end
function cm.eff03_tar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
		--Duel.SetChainLimit(cm.chlimit)
	end
end

function cm.chlimit(e,ep,tp)
	return tp==ep
end

function cm.eff03_op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		if Duel.Remove(eg,POS_FACEUP,REASON_EFFECT) then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(m,0))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetValue(2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
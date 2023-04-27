--애쉬블룸 크리메이션
local m=47210024
local cm=_G["c"..m]

local payed=false

function cm.initial_effect(c)

	--Effect_01
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,m,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(cm.eff01_cost)
	e1:SetTarget(cm.eff01_tar)
	e1:SetOperation(cm.eff01_op)
	c:RegisterEffect(e1)

	--Effect_02
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,2))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,m,EFFECT_COUNT_CODE_OATH)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCost(cm.eff01_cost)
	e2:SetTarget(cm.eff02_tar)
	e2:SetOperation(cm.eff02_op)
	c:RegisterEffect(e2)

	--Effect_00
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0:SetDescription(aux.Stringid(m,0))
	e0:SetValue(function(e,c) e:SetLabel(1) end)
	e0:SetCondition(function(e) return Duel.IsExistingMatchingCard(cm.eff00_filter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil) end)
	c:RegisterEffect(e0)
	e1:SetLabelObject(e0)
	e2:SetLabelObject(e0)

end


function cm.eff00_filter(c)
	return c:IsSetCard(0xa7b) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end

function cm.eff01_cost(e,tp,eg,ep,ev,re,r,rp,chk)

	if chk==0 then e:GetLabelObject():SetLabel(0) return true end

	if e:GetLabelObject():GetLabel()>0 then
		e:GetLabelObject():SetLabel(0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,cm.eff00_filter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		payed=true
	end
end

function cm.eff01_addcost(e,tp,eg,ep,ev,re,r,rp,chk)

	if chk==0 then return Duel.IsExistingMatchingCard(cm.eff00_filter,tp,LOCATION_GRAVE,0,1,nil) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cm.eff00_filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function cm.eff01_tar(e,tp,eg,ep,ev,re,r,rp,chk)

	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:IsHasType(EFFECT_TYPE_ACTIVATE) 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,m,0xa7b,TYPE_MONSTER|TYPE_NORMAL,0,1600,3,RACE_PLANT,ATTRIBUTE_FIRE,POS_FACEUP) end
	if payed==false and cm.eff01_addcost(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
		cm.eff01_addcost(e,tp,eg,ep,ev,re,r,rp,1)
		payed=true
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	payed=false

end

function cm.eff01_op(e,tp,eg,ep,ev,re,r,rp)

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	local c=e:GetHandler()

	if c:IsRelateToEffect(e)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,m,0xa7b,TYPE_MONSTER|TYPE_NORMAL,0,1600,3,RACE_PLANT,ATTRIBUTE_FIRE,POS_FACEUP) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
		c:AddMonsterAttributeComplete()
		Duel.SpecialSummonComplete()
	end

end


function cm.eff02_filter(c,tp)
	return c:IsSetCard(0xa7b) and c:IsControler(tp)
end

function cm.eff02_check(sg,e,tp)
	return sg:IsExists(cm.eff02_filter,1,nil,tp)
end

function cm.eff02_tar(e,tp,eg,ep,ev,re,r,rp,chk,chkc)

	if chk==0 then return Duel.IsExistingMatchingCard(cm.eff02_filter,tp,LOCATION_GRAVE,0,1,nil,tp) and Duel.IsExistingMatchingCard(nil,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,nil) end

	if payed==false and cm.eff01_addcost(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
		cm.eff01_addcost(e,tp,eg,ep,ev,re,r,rp,1)
		payed=true
	end

	local g2=Duel.GetMatchingGroup(nil,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)

	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,1,0,0)
	payed=false
end

function cm.eff02_op(e,tp,eg,ep,ev,re,r,rp)

	local g1=Duel.SelectMatchingCard(tp,cm.eff02_filter,tp,LOCATION_GRAVE,0,1,1,nil,tp)

	if #g1<1 then return end

	local g2=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,2,g1)

	g1:Merge(g2)

	if #g1>0 then
		Duel.HintSelection(g1)
		Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
	end
end
--아네모네 애쉬블룸
local m=47210032
local cm=_G["c"..m]

function cm.initial_effect(c)
	
	--Link summon method
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PLANT),2,nil,cm.matcheck)

	--Effect_01
	c:SetUniqueOnField(1,0,m)

	--Effect_02
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,m)
	e2:SetTarget(cm.eff02_tar)
	e2:SetOperation(cm.eff02_op)
	c:RegisterEffect(e2)

	--Effect_03
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1)
	e3:SetCost(cm.eff03_cost)
	e3:SetTarget(cm.eff03_tar)
	e3:SetOperation(cm.eff03_op)
	c:RegisterEffect(e3)
	
end

function cm.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0xa7b,lc,sumtype,tp)
end


function cm.eff02_filter(c)
	return c:IsSetCard(0xa7b) and c:IsSSetable() and c:IsType(TYPE_SPELL+TYPE_TRAP) and (c:IsLocation(LOCATION_GRAVE) or (c:IsFaceup() and c:IsLocation(LOCATION_REMOVED)))
end

function cm.eff02_tar(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.eff02_filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end

function cm.eff02_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)

	local tc=Duel.SelectMatchingCard(tp,cm.eff02_filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil):GetFirst()

	if tc then
		Duel.SSet(tp,tc)
		if tc.act_turn then
			local e0=Effect.CreateEffect(tc)
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e0:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e0)
		end
	end
end

function cm.eff03_filter(c,tp)
	return c:IsSetCard(0xa7b) and c:IsAbleToRemoveAsCost() and c:IsTrap()
end

function cm.eff03_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.eff03_filter,tp,LOCATION_GRAVE,0,2,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cm.eff03_filter,tp,LOCATION_GRAVE,0,2,2,nil,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function cm.eff03_tar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function cm.eff03_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
--아이리스 애쉬블룸

local m=47210001
local cm=_G["c"..m]

function cm.initial_effect(c)
	
	--Effect_01
	c:SetUniqueOnField(1,0,m)

	--Effect_02
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,m)
	e2:SetCost(cm.eff02_cost)
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
	e3:SetTarget(cm.eff03_tar)
	e3:SetOperation(cm.eff03_op)
	c:RegisterEffect(e3)

end


function cm.eff02_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end

function cm.eff02_filter(c)

	return c:IsSetCard(0xa7b) and c:IsSSetable() and c:IsType(TYPE_SPELL+TYPE_TRAP)

end

function cm.eff02_tar(e,tp,eg,ep,ev,re,r,rp,chk)

	if chk==0 then return Duel.IsExistingMatchingCard(cm.eff02_filter,tp,LOCATION_DECK,0,1,nil) end

end

function cm.eff02_op(e,tp,eg,ep,ev,re,r,rp)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)

	local tc=Duel.SelectMatchingCard(tp,cm.eff02_filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()

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



function cm.eff03_tar(e,tp,eg,ep,ev,re,r,rp,chk)

	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,LOCATION_REMOVED)

end

function cm.eff03_op(e,tp,eg,ep,ev,re,r,rp)

	local c=e:GetHandler()

	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_REMOVED) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then

		--Return it to deck if it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3301)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKBOT)
		c:RegisterEffect(e1,true)

	end

end
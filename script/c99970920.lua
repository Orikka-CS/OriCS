--[ Trie Elow ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetValue(function(e,c) e:SetLabel(1) end)
	e2:SetCondition(function(e) return Duel.IsCanRemoveCounter(e:GetHandlerPlayer(),1,0,COUNTER_SPELL,3,REASON_COST) end)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(s.cost3)
	e3:SetTarget(s.tar3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
	
end

s.counter_place_list={COUNTER_SPELL}

function s.cost1fil(c)
	return c:IsSetCard(0x9d6f) and c:IsAbleToGraveAsCost()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local label_obj=e:GetLabelObject()
	if chk==0 then label_obj:SetLabel(0) return Duel.IsExistingMatchingCard(s.cost1fil,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil) end
	if label_obj:GetLabel()>0 then
		label_obj:SetLabel(0)
		Duel.RemoveCounter(tp,1,0,COUNTER_SPELL,3,REASON_COST)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cost1fil,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.op1fil(c)
	return c:IsFaceup() and c:IsCanAddCounter(COUNTER_SPELL,2)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,1-tp,LOCATION_MZONE,0,nil,POS_FACEUP,REASON_RULE)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,30459350) and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_MZONE)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsPlayerAffectedByEffect(1-tp,30459350) then return end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,1-tp,LOCATION_MZONE,0,nil,POS_FACEUP,REASON_RULE)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local sg=g:Select(1-tp,1,1,nil)
		Duel.HintSelection(sg)
		if Duel.Remove(sg,POS_FACEUP,REASON_RULE,PLAYER_NONE,1-tp)>0 and not c:IsStatus(STATUS_SET_TURN) then
			local cg=Duel.SelectMatchingCard(tp,s.op1fil,tp,LOCATION_MZONE,0,1,1,nil)
			if #cg>0 then
				Duel.BreakEffect()
				cg:GetFirst():AddCounter(COUNTER_SPELL,2)
			end
		end
	end
	if not c:IsRelateToEffect(e) then return end
	if c:IsSSetable(true) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.BreakEffect()
		c:CancelToGrave()
		Duel.ChangePosition(c,POS_FACEDOWN)
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end

function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST)
end
function s.tar3fil(c)
	return c:IsSetCard(0x9d6f) and c:IsSpellTrap() and c:IsSSetable()
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.tar2fil(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tar3fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectTarget(tp,s.tar3fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,e:GetHandler())
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsSSetable() then
		Duel.SSet(tp,tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3300)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
	end
end

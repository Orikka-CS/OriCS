--[ Trie Elow ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_COUNTER)
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
	e2:SetLabelObject(e1)
	e2:SetValue(function(e,c) return e:GetLabelObject():SetLabel(1) end)
	e2:SetCondition(function(e) return Duel.IsCanRemoveCounter(e:GetHandlerPlayer(),1,0,COUNTER_SPELL,3,REASON_COST) end)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	
end

s.counter_place_list={COUNTER_SPELL}

function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then e:SetLabel(0) return true end
	if e:GetLabel()>0 then
		e:SetLabel(0)
		Duel.RemoveCounter(tp,1,0,COUNTER_SPELL,3,REASON_COST)
	end
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local sc=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x9d6f),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return sc>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCanTurnSet),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,1,1,0,0)
end
function s.op1fil(c)
	return c:IsFaceup() and c:IsCanAddCounter(COUNTER_SPELL,2)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x9d6f),tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsCanTurnSet),tp,LOCATION_MZONE,LOCATION_MZONE,1,ct,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)>0 and not c:IsStatus(STATUS_SET_TURN) then
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

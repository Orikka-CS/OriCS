--[ Trie Elow ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_COUNTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
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
	
end

s.counter_place_list={COUNTER_SPELL}

function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local label_obj=e:GetLabelObject()
	if chk==0 then label_obj:SetLabel(0) return true end
	if label_obj:GetLabel()>0 then
		label_obj:SetLabel(0)
		Duel.RemoveCounter(tp,1,0,COUNTER_SPELL,3,REASON_COST)
	end
end
function s.tarfil(c,e,tp)
	return c:IsCanBeEffectTarget(e) and (c:IsControler(1-tp) or (c:IsFaceup() and c:IsMonster() and c:IsSetCard(0x9d6f)))
end
function s.tar1con(sg,e,tp,mg)
    local own=sg:FilterCount(Card.IsControler,nil,tp)
    return own==1,own>1
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tarfil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e,tp)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,3,3,s.tar1con,0) end
	local dg=aux.SelectUnselectGroup(g,e,tp,3,3,s.tar1con,1,tp,HINTMSG_DESTROY)
	Duel.SetTargetCard(dg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
end
function s.op1fil(c)
	return c:IsFaceup() and c:IsCanAddCounter(COUNTER_SPELL,2)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	if #tg>0 and Duel.Destroy(tg,REASON_EFFECT)>0 and not c:IsStatus(STATUS_SET_TURN) then
		local g=Duel.SelectMatchingCard(tp,s.op1fil,tp,LOCATION_MZONE,0,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			g:GetFirst():AddCounter(COUNTER_SPELL,2)
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

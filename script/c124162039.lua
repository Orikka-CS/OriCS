--비블리오션 토트 울티마툴
local s,id=GetID()
function s.initial_effect(c)
	--fusion
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x6f20),3)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.cst1filter(c,tp)
	local ignore=Duel.GetLocationCount(tp,LOCATION_SZONE)==0 and c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5
	return c:IsContinuousSpell() and c:IsAbleToGraveAsCost()
		and Duel.GetMatchingGroupCount(s.tg1filter,tp,LOCATION_DECK,0,nil,ignore)>0
end
function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,tp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(sg,REASON_COST)
end
function s.tg1filter(c,ignore)
	return c:IsSetCard(0x6f20) and c:IsSpellTrap() and c:IsSSetable(ignore)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil,true)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil,false)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SET)
	if Duel.SSet(tp,sg)==0 then return end
	local dg=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		local dsg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SELECT):GetFirst()
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(dsg,SEQ_DECKTOP)
		Duel.DisableShuffleCheck()
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x6f20)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,tp)>0
end
function s.cst2filter(c)
	return c:IsContinuousSpell() and c:IsAbleToDeckAsCost()
end
function s.cst2ct(tp)
	local ct=0
	if Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil,tp)>0 then ct=ct+1 end
	if Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil,tp)>0 then ct=ct+1 end
	if Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil,tp)>0 then ct=ct+1 end
	return ct
end
function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=s.cst2ct(tp)
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 and ct>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.TRUE,1,tp,HINTMSG_TODECK)
	e:SetLabel(#sg)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.cst2ct(tp)>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,e:GetLabel(),1-tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #hg>0 then Duel.ConfirmCards(tp,hg) end
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil,tp)
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil,tp)
	local g3=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,nil,tp)
	local b1,b2,b3=#g1>0,#g2>0,#g3>0
	local ct=(b1 and 1 or 0)+(b2 and 1 or 0)+(b3 and 1 or 0)
	local dt=e:GetLabel()
	if dt>ct then
		if #hg>0 then Duel.ShuffleHand(1-tp) end
		return
	end
	local sg=Group.CreateGroup()
	for i=1,dt do
		local b=Duel.SelectEffect(tp,{b1,aux.Stringid(id,3)},{b2,aux.Stringid(id,4)},{b3,aux.Stringid(id,5)})
		if b==1 then
			sg:Merge(aux.SelectUnselectGroup(g1,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE))
			b1=false
		elseif b==2 then
			sg:Merge(aux.SelectUnselectGroup(g2,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE))
			b2=false
		else
			sg:Merge(aux.SelectUnselectGroup(g3,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE))
			b3=false
		end
	end
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	if #hg>0 then Duel.ShuffleHand(1-tp) end
end

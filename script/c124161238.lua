--테일모어 구르메 카라멜리아
local s,id=GetID()
function s.initial_effect(c)
	--synchro
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf2f),1,1,Synchro.NonTuner(nil),1,99)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.PayLP(900))
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 and Duel.GetDecktopGroup(tp,3):FilterCount(Card.IsAbleToHand,nil)>0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.op1filter(c,e,tp)
	return c:IsAbleToHand() and not c:IsContinuousSpell() 
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local ac=3
	Duel.ConfirmDecktop(tp,ac)
	local g=Duel.GetDecktopGroup(tp,ac)
	g=g:Filter(s.op1filter,nil)
	if #g>0 then	
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND):GetFirst()
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
	Duel.ShuffleDeck(tp)
	local dg=Duel.GetMatchingGroup(Card.IsContinuousSpell,tp,LOCATION_DECK,0,nil)   
	if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()   
		local dsg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SELECT):GetFirst()
		Duel.MoveSequence(dsg,0)
		Duel.ConfirmDecktop(tp,1)
		Duel.DisableShuffleCheck()
	end
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsSetCard(0xf2f) and e:GetHandler()~=rc and rp==tp
end

function s.cst2filter(c)
	return c:IsContinuousSpell() and c:IsAbleToDeckAsCost()
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=0
	if Duel.GetMatchingGroupCount(Card.IsAbleToDeck,tp,0,LOCATION_HAND,nil)>0 then ct=ct+1 end
	if Duel.GetMatchingGroupCount(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)>0 then ct=ct+1 end
	if Duel.GetMatchingGroupCount(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,nil)>0 then ct=ct+1 end
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_HAND+LOCATION_SZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.dpcheck(Card.GetLocation),1,tp,HINTMSG_TODECK)
	e:SetLabel(#sg)
	Duel.ConfirmCards(1-tp,sg)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=0
	if Duel.GetMatchingGroupCount(Card.IsAbleToDeck,tp,0,LOCATION_HAND,nil)>0 then ct=ct+1 end
	if Duel.GetMatchingGroupCount(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)>0 then ct=ct+1 end
	if Duel.GetMatchingGroupCount(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,nil)>0 then ct=ct+1 end
	if chk==0 then return ct>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=0
	local dt=e:GetLabel()
	local g1=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_HAND,nil)
	local g2=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	local g3=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,nil)
	local sg=Group.CreateGroup()
	local b1=false
	local b2=false
	local b3=false
	if #g1>0 then 
		b1=true
		ct=ct+1
	end
	if #g2>0 then 
		b2=true
		ct=ct+1
	end
	if #g3>0 then 
		b3=true
		ct=ct+1
	end
	if dt>ct then return end
	local b 
	for i=1,dt do
		b=Duel.SelectEffect(tp,{b1,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)},{b3,aux.Stringid(id,3)})
		if b==1 then
			sg=sg+g1:RandomSelect(tp,1)
			b1=false
		end
		if b==2 then
			sg=sg+aux.SelectUnselectGroup(g2,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
			b2=false
		end
		if b==3 then
			sg=sg+aux.SelectUnselectGroup(g3,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
			b3=false
		end
	end 
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
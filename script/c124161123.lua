--캘라피스 서멀쇼크
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SSET)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf27)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_MZONE,0,nil)>0 and Duel.IsChainNegatable(ev) and rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,1-tp,re:GetHandler():GetLocation())
	end
	if e:GetHandler():IsPreviousLocation(LOCATION_REMOVED) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		e:SetLabel(1)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
	else
		e:SetLabel(0)
	end 
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not Duel.NegateActivation(ev) or not rc:IsRelateToEffect(re) then return end
	if Duel.Destroy(rc,REASON_EFFECT)==0 then return end
	local cd=rc:GetCode()
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if e:GetLabel()==1 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DESTROY)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end

--effect 2
function s.tg2filter(c)
	return c:IsSetCard(0xf27) and c:IsFaceup() and c:IsAbleToDeck()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)  
	local c=e:GetHandler()
	local dg=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_REMOVED,0,c)
	if chk==0 then return #dg>0 and c:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,dg+c,1,0,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dg=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_REMOVED,0,c)
	if #dg>0 and c:IsRelateToEffect(e) then
		local dsg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)  
		Duel.SendtoDeck(dsg+c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) 
		Duel.ShuffleDeck(tp)
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
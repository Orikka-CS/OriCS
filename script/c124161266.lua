--메가히트 셀리스티 안젤리카
local s,id=GetID()
function s.initial_effect(c)
	--link
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,nil,s.linkfilter)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.tg2)
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	local e2a=e2:Clone()
	e2a:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2a:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2a:SetValue(aux.tgoval)
	c:RegisterEffect(e2a)
end

--link
function s.linkfilter(g,lnkc,sumtype,sp)
	return g:IsExists(Card.IsSetCard,1,nil,0xf31,lnkc,sumtype,sp)
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsSetCard(0xf31) and rp==tp
end

function s.cst1filter(c)
	return c:IsSetCard(0xf31) and c:IsAbleToDeckAsCost()
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_GRAVE,0,c)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_COST)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetFlagEffect(tp,124161269)
	if chk==0 then return ct>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct*2 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.op1filter(c)
	return c:IsSetCard(0xf31) and c:IsAbleToHand()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFlagEffect(tp,124161269)
	local ac=ct*2
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ac then
		local g=Duel.GetDecktopGroup(tp,ac)
		Duel.ConfirmCards(tp,g)
		g=g:Filter(s.op1filter,nil,e,tp)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then	
			local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
			Duel.DisableShuffleCheck()
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleHand(tp)
			ac=ac-1
		end
		Duel.SortDecktop(tp,tp,ac)
	end
end

--effect 2
function s.tg2(e,c)
	return c:IsFaceup() and c:IsSetCard(0xf31)
end
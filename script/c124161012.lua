--일광형의 성전
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf20) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetTarget(s.tg3)
	c:RegisterEffect(e3)
	local e3a=e3:Clone()
	e3a:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e3a)
end

--effect 1
function s.val1filter(c)
	return c:IsPublic()  
end

function s.val1(e,c)
	return Duel.GetMatchingGroupCount(s.val1filter,e:GetHandlerPlayer(),LOCATION_HAND,0,nil)*300
end

--effect 2

function s.cst2ffilter(c,code)
	return c:IsSetCard(0xf20) and not c:IsCode(code) and c:IsAbleToHand() and not c:IsType(TYPE_FIELD)
end

function s.cst2filter(c,tp)
	return not c:IsPublic() and c:IsSetCard(0xf20) and Duel.IsExistingMatchingCard(s.cst2ffilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_HAND,0,nil,tp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONFIRM):GetFirst()
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(tp)
	e:SetLabel(sg:GetCode())
end


function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	local hg=Duel.GetMatchingGroup(s.cst2ffilter,tp,LOCATION_DECK,0,nil,code)
	if #hg>0 then
		local hsg=aux.SelectUnselectGroup(hg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		if Duel.SendtoHand(hsg,nil,REASON_EFFECT) then
			Duel.ConfirmCards(1-tp,hsg)
			Duel.ShuffleDeck(tp)
			Duel.BreakEffect()
			Duel.DisableShuffleCheck()
			local dg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND,0,nil)
			local sdg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
			Duel.SendtoDeck(sdg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end

--effect 3
function s.tg3(e,c)
	return c:IsPublic() and c:IsSetCard(0xf20)
end

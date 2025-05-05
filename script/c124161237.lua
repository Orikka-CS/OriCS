--테일모어 뱅퀴트
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
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf2f) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTarget(s.tg3)
	e3:SetOperation(s.op3)
	e3:SetValue(function(e,c) return s.val3filter(c,e,e:GetHandlerPlayer()) end)
	c:RegisterEffect(e3)
end

--effect 1
function s.val1filter(c)
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsContinuousSpell()
end

function s.val1(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.GetMatchingGroupCount(s.val1filter,tp,LOCATION_GRAVE,0,nil)*300
end

--effect 2
function s.con2filter(c,tp)
	return c:IsControler(tp) and c:IsContinuousSpell()
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.con2filter,1,nil,tp)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.op2filter(c)
	return c:IsSetCard(0xf2f) and c:IsAbleToHand() and not c:IsType(TYPE_FIELD)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local ac=3
	Duel.ConfirmDecktop(tp,ac)
	local g=Duel.GetDecktopGroup(tp,ac)
	g=g:Filter(s.op2filter,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then	
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND):GetFirst()
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
	Duel.ShuffleDeck(tp)
end

--effect 3
function s.val3filter(c,e,tp)
	return c:IsSetCard(0xf2f) and c:IsFaceup() and c:IsControler(tp) and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c~=e:GetHandler()
end

function s.tg3filter(c)
	return c:IsContinuousSpell() and c:IsAbleToDeck()
end

function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg3filter,tp,LOCATION_GRAVE,0,eg)
	if chk==0 then return eg:IsExists(s.val3filter,1,nil,e,tp) and #g>0 end
	return Duel.SelectYesNo(tp,aux.Stringid(id,1))
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg3filter,tp,LOCATION_GRAVE,0,eg)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT+REASON_REPLACE)
	Duel.Hint(HINT_CARD,0,id)
end
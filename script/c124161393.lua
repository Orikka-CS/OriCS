--콘트라기온 에피센터
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
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf39) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
	e3:SetTarget(s.tg3)
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
	local e3a=e3:Clone()
	e3a:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e3a)
	local e3b=e3:Clone()
	e3b:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e3b)
end

--effect 1
function s.val1filter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end

function s.val1(e,c)
	return Duel.GetMatchingGroupCount(s.val1filter,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)*100
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:FilterCount(Card.IsLocation,nil,LOCATION_ONFIELD)>0
end

function s.tg2ifilter(c,e)
	return c:IsSetCard(0xf39) and not c:IsType(TYPE_FIELD) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end

function s.tg2ofilter(c,e)
	return c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g1=Duel.GetMatchingGroup(s.tg2ifilter,tp,LOCATION_GRAVE,0,nil,e)
	local g2=Duel.GetMatchingGroup(s.tg2ofilter,tp,0,LOCATION_ONFIELD,nil,e) 
	if chk==0 then return #g1>0 and #g2>0 end
	local sg1=aux.SelectUnselectGroup(g1,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
	local sg2=aux.SelectUnselectGroup(g2,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
	sg1:Merge(sg2)
	Duel.SetTargetCard(sg1)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg1,2,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)
		local og=Duel.GetOperatedGroup()
		if og:FilterCount(Card.IsCode,nil,124161384)>0 and Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.DisableShuffleCheck()
			Duel.DiscardDeck(tp,1,REASON_EFFECT)
		end
	end
end

--effect 3
function s.tg3(e,c)
	return c:IsType(TYPE_TUNER)
end

function s.val3(e,c)
	if not c then return false end
	return c:IsControler(1-e:GetHandlerPlayer())
end
--란샤르드 리비도 브리스
local s,id=GetID()
function s.initial_effect(c)
	--fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf2e),s.mfilter)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) return c:IsSetCard(0xf2e) end)
	c:RegisterEffect(e2)
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_CANNOT_TO_DECK)
	e2a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetTargetRange(0,1)
	e2a:SetTarget(s.tg2)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EFFECT_CANNOT_TO_HAND)
	e2b:SetTarget(s.tg2ex)
	c:RegisterEffect(e2b)
end

--fusion
function s.mfilter(c,sc,st,tp)
	return c:IsType(TYPE_EFFECT,sc,st,tp) and c:IsLocation(LOCATION_MZONE)
end

--effect 1
function s.tg1filter(c,e)
	return c:IsFaceup() and c:IsAbleToChangeControler() and c:IsCanBeEffectTarget(e)
end

function s.tg1gfilter(c)
	return c:IsSetCard(0xf2e) and c:IsMonster() and not c:IsType(TYPE_EXTRA)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_MZONE,nil,e)
	local gg=Duel.GetMatchingGroup(s.tg1gfilter,tp,LOCATION_GRAVE,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tg1filter(chkc,e) end
	if chk==0 then return #gg>0 and #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONTROL)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,gg,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,sg,1,tp,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local gg=Duel.GetMatchingGroup(s.tg1gfilter,tp,LOCATION_GRAVE,0,nil)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if #gg>0 then
		local gsg=aux.SelectUnselectGroup(gg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONTROL):GetFirst()
		Duel.SendtoHand(gsg,1-tp,REASON_EFFECT)
		if gsg:IsLocation(LOCATION_HAND) and tg then
			Duel.BreakEffect()
			Duel.GetControl(tg,tp)
		end
	end
end

--effect 2
function s.tg2(e,c,tp,r)
	return c:IsSetCard(0xf2e) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(e:GetHandlerPlayer())
end

function s.tg2ex(e,c)
	return c:GetOriginalType()&TYPE_EXTRA~=0 and c:IsSetCard(0xf2e) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(e:GetHandlerPlayer())
end
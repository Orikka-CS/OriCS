--란샤르드 위즈 아딘
local s,id=GetID()
function s.initial_effect(c)
	--fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf2e),aux.FilterBoolFunctionEx(Card.IsLocation,LOCATION_HAND))
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,1-tp,LOCATION_HAND)
end

function s.op1filter(c)
	return c:IsSetCard(0xf2e) and c:IsMonster()
end

function s.op1dfilter(c,tp)
	return c:IsAbleToGrave() and c:GetOwner()==1-tp
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.Draw(tp,1,REASON_EFFECT) then return end
	local g=Duel.GetMatchingGroup(s.op1filter,tp,LOCATION_HAND,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg,1-tp,REASON_EFFECT)
		local dg=Duel.GetMatchingGroup(s.op1dfilter,tp,0,LOCATION_HAND,nil,tp)
		if #dg==0 then return end
		local dsg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,1-tp,HINTMSG_TOGRAVE)
		Duel.SendtoGrave(dsg,REASON_EFFECT)
	end 
end

--effect 2
function s.tg2filter(c)
	return c:IsSetCard(0xf2e) and c:IsSpellTrap() and c:IsSSetable()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and #g>0 end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SET)
		Duel.SSet(tp,sg) 
	end
end
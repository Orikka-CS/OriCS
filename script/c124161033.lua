--엄브라레 틸라
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
end

--effect 1
function s.cst1filter(c)
	return c:IsSetCard(0xf22) and c:IsType(TYPE_LINK) and c:IsFacedown()
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONFIRM)
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleExtra(tp)
end

function s.tg1filter(c)
	return c:IsSetCard(0xf22) and not c:IsCode(id) and c:IsAbleToGrave()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,tp,LOCATION_HAND+LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE):GetFirst()
		if sg:IsLocation(LOCATION_REMOVED) then 
			Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN) 
		end
		if sg:IsLocation(LOCATION_DECK) then 
			Duel.SendtoGrave(sg,REASON_EFFECT) 
		end
		if sg:IsLocation(LOCATION_HAND) and Duel.SendtoGrave(sg,REASON_EFFECT)>0 and Duel.IsPlayerCanDraw(tp,1) and sg:GetLocation()==LOCATION_GRAVE then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

--effect 2
function s.val2filter(c)
	return c:IsFacedown()
end

function s.val2(e,c)
	local tp=c:GetControler()
	local zone=0
	local lg=Duel.GetMatchingGroup(s.val2filter,tp,0,LOCATION_STZONE,nil)
	for tc in aux.Next(lg) do
		zone=(zone|tc:GetColumnZone(LOCATION_MZONE,0,0,tp))
	end
	return 0,zone
end
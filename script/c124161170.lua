--백연초의 회진
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0xf2b)}
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1(Fusion.SummonEffTG(params),Fusion.SummonEffOP(params)))
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
	Duel.ConfirmCards(1-tp,c)
	Duel.ShuffleHand(tp)
end

function s.tg1filter(c,e,tp)
	return c:IsSetCard(0xf2b) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_HAND,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_HAND)
end

function s.op1(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end 
		local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_HAND,0,nil,e,tp)
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		if fustg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			fusop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end

--efffect 2
function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,700) end
	Duel.PayLPCost(tp,700)
end

function s.tg2filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf2b) and c:IsAbleToDeck()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_REMOVED,0,nil)
	if chk==0 then return #g>0 and c:IsAbleToDeck() and Duel.IsPlayerCanDraw(tp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_REMOVED,0,nil)
	if #g>0 and c:IsRelateToEffect(e) then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
		Duel.SendtoDeck(c+sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
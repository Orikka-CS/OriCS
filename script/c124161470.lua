--브릿지버스터 플레어
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c)
	return c:IsSetCard(0xf3e) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,4,1-tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,4,1-tp,LOCATION_GRAVE)
end

function s.op1filter(c)
	return c:IsAbleToDeck()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleDeck(tp)
			if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>3 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.BreakEffect()
				Duel.DiscardDeck(1-tp,4,REASON_EFFECT)
				local dg=Duel.GetMatchingGroup(s.op1filter,tp,0,LOCATION_GRAVE,nil)
				if #dg>0 then
					Duel.BreakEffect()
					Duel.DisableShuffleCheck()
					local dsg=aux.SelectUnselectGroup(dg,e,tp,1,4,aux.TRUE,1,tp,HINTMSG_TODECK)
					if Duel.SendtoDeck(dsg,nil,SEQ_DECKTOP,REASON_EFFECT)>0 then
						local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK)
						if #og>1 then
							Duel.SortDecktop(tp,1-tp,#og)
						end
					end
				end
			end
		end
	end
end

--effect 2
function s.tg2filter(c,e)
	return c:IsSetCard(0xf3e) and c:IsFaceup() and c:IsCanBeEffectTarget(e)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g1=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_ONFIELD,0,nil,e)
	local g2=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return #g1>0 and #g2>1 end
	local sg1=aux.SelectUnselectGroup(g1,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DESTROY)
	local sg2=aux.SelectUnselectGroup(g2,e,tp,2,2,aux.TRUE,1,tp,HINTMSG_DESTROY)
	sg1:Merge(sg2)
	Duel.SetTargetCard(sg1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg1,#sg1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
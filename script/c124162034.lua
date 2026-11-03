--비블리오션 아틀라
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e2a=e2:Clone()
	e2a:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2a)
end

--effect 1
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.ConfirmDecktop(tp,4)
	local g=Duel.GetDecktopGroup(tp,4):Filter(Card.IsContinuousSpell,nil)
	local c=e:GetHandler()
	if #g>0 then
		if Duel.SendtoGrave(g,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
	elseif c:IsRelateToEffect(e) then
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
	Duel.ShuffleDeck(tp)
end

--effect 2
function s.tg2filter(c)
	return c:IsSetCard(0x6f20) and c:IsSpell() and c:IsSSetable()
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 and (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or g:IsExists(Card.IsType,1,nil,TYPE_FIELD)) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD)
end
function s.op2filter(c)
	return c:IsSpellTrap() and c:IsAbleToDeck()
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then g=g:Filter(Card.IsType,nil,TYPE_FIELD) end
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SET)
	if Duel.SSet(tp,sg)==0 then return end
	Duel.ShuffleDeck(tp)
	local dg=Duel.GetMatchingGroup(s.op2filter,tp,LOCATION_ONFIELD,0,nil)
	if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		local dsg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
		Duel.DisableShuffleCheck()
		Duel.SendtoDeck(dsg,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end

--나바슈파타 리디렉션
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf3d) and c:IsOriginalType(TYPE_MONSTER)
end

function s.tg1bfilter(c,tp)
	return c:IsFacedown() or not (c:IsFaceup() and c:IsOriginalType(TYPE_SYNCHRO) and c:IsControler(tp))
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_ONFIELD,0,nil)
	local g=Group.CreateGroup()
	for tc in cg:Iter() do
		g:Merge(tc:GetColumnGroup())
	end
	g:Merge(cg)
	g=g:Filter(s.tg1bfilter,nil,tp)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.op1filter(c,e,tp)
	return c:IsSetCard(0xf3d) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local cg=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_ONFIELD,0,nil)
	local g=Group.CreateGroup()
	for tc in cg:Iter() do
		g:Merge(tc:GetColumnGroup())
	end
	g:Merge(cg)
	g=g:Filter(s.tg1bfilter,nil,tp)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsSetCard,nil,0xf3d)
		local spg=Duel.GetMatchingGroup(s.op1filter,tp,LOCATION_HAND,0,nil,e,tp)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft>0 and #spg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
			local max=math.min(ct+1,ft)
			local sg=aux.SelectUnselectGroup(spg,e,tp,1,max,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

--effect 2
function s.tg2filter(c,e)
	return c:IsSetCard(0xf3d) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e) and c:IsFaceup()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and chkc~=c and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,c,e)
	if chk==0 then return #g>3 and c:IsAbleToHand() end
	local sg=aux.SelectUnselectGroup(g,e,tp,4,4,aux.TRUE,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	if #tg>0 and Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
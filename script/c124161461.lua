--브릿지버스터 체서피크
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--count
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.cnt)
		Duel.RegisterEffect(ge1,0)
	end)
end

--count
function s.cntfilter(c,p)
	return c:IsMonster() and c:IsControler(p) and c:IsLocation(LOCATION_GRAVE)
end

function s.cnt(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		if eg:FilterCount(s.cntfilter,nil,p)>1 and not (Duel.GetFlagEffect(p,id)>0) then
			Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.GetFlagEffect(tp,id)==0
end

function s.tg1filter(c)
	return c:IsSetCard(0xf3e) and c:IsSpell() and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_GRAVE)
end

function s.op1filter(c)
	return c:IsMonster() and c:IsAbleToDeck()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleDeck(tp)
			local dg=Duel.GetMatchingGroup(s.op1filter,tp,0,LOCATION_GRAVE,nil)
			if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.BreakEffect()
				Duel.DisableShuffleCheck()
				local dsg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
				Duel.SendtoDeck(dsg,nil,SEQ_DECKTOP,REASON_EFFECT)
			end
		end
	end
end

--effect 2
function s.cst2filter(c)
	return c:IsSetCard(0xf3e) and c:IsType(TYPE_XYZ) and not c:IsPublic()
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONFIRM)
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleExtra(tp)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,LOCATION_GRAVE)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
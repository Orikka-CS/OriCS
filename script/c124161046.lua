--앰부쉬 엄브라레
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1ifilter(c) 
	return c:IsSetCard(0xf22) and c:IsSpellTrap() and c:IsSSetable() and not c:IsCode(id) and not c:IsType(TYPE_FIELD)
end

function s.tg1ocheck(e,tp,eg,ep,ev,re,r,rp)
	if (re and re:GetHandler():IsSetCard(0xf22) and re:GetHandler():GetOwner()==1-tp) then return end
	local sg=eg:Filter(Card.IsType,nil,TYPE_SPELL+TYPE_TRAP)
	for ec in sg:Iter() do
		ec:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD)
	end
end

function s.tg1ofilter(c,tp)
	return c:IsFacedown() and c:IsSpellTrap() and c:IsAbleToDeck() and c:GetOwner()==tp 
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetHandler():GetOwner()==tp then
			local ig=Duel.GetMatchingGroup(s.tg1ifilter,tp,LOCATION_DECK,0,nil) 
			return #ig>0 and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0
		else
			e:SetCategory(CATEGORY_TODECK)
			local og=Duel.GetMatchingGroup(s.tg1ofilter,tp,LOCATION_STZONE,0,nil,tp)
			return #og>0
		end
	end
	if e:GetHandler():GetOwner()==1-tp then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,og,1,0,LOCATION_STZONE)
	end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp,owner)
	local op=nil
	if owner then
		op=owner
	else
		if e:GetHandler():GetOwner()==tp then
			op=1
		else
			op=2
		end
	end
	if op==1 then
		local ig=Duel.GetMatchingGroup(s.tg1ifilter,tp,LOCATION_DECK,0,nil) 
		if #ig==0 and Duel.GetLocationCount(1-tp,LOCATION_SZONE)<1 then return end
		local sig=aux.SelectUnselectGroup(ig,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SET)
		Duel.SSet(tp,sig,1-tp)
	else
		local og=Duel.GetMatchingGroup(s.tg1ofilter,tp,LOCATION_STZONE,0,nil,tp)
		if #og==0 then return end
		local sog=aux.SelectUnselectGroup(og,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
		Duel.ConfirmCards(1-tp,sog)
		Duel.SendtoDeck(sog,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsSetCard(0xf22) and c:IsFaceup() and c:IsControler(tp)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.con2filter,1,nil,tp)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 and c:IsSSetable() end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 then
		if Duel.SSet(tp,c,1-tp)>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_DECKBOT)
			c:RegisterEffect(e1)
		end
	end
end
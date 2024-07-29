--Defense Umbrare
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
	return c:IsMonster() and c:IsSetCard(0xf22) and c:IsFaceup()
end

function s.tg1ofilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsCanTurnSet() and c:IsStatus(STATUS_SPSUMMON_TURN)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetHandler():GetOwner()==tp then
			local ig=Duel.GetMatchingGroup(s.tg1ifilter,tp,LOCATION_MZONE,0,nil) 
			return #ig>0
		else
			e:SetCategory(CATEGORY_POSITION)
			local og=Duel.GetMatchingGroup(s.tg1ofilter,tp,LOCATION_MZONE,0,nil)
			return #og>0
		end
	end
	if e:GetHandler():GetOwner()==1-tp then
		Duel.SetOperationInfo(0,CATEGORY_POSITION,og,#og,tp,LOCATION_MZONE)
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
		local ig=Duel.GetMatchingGroup(s.tg1ifilter,tp,LOCATION_MZONE,0,nil)
		if #ig==0 then return end
		for tc in ig:Iter() do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	else
		local og=Duel.GetMatchingGroup(s.tg1ofilter,tp,LOCATION_MZONE,0,nil)
		if #og==0 then return end
		Duel.ChangePosition(og,POS_FACEDOWN_DEFENSE)
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup() and c:IsControler(tp)
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
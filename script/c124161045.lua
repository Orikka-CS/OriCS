--힌드런스 엄브라레
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
function s.tg1setfilter(c) 
	return c:IsFacedown()
end

function s.tg1negfilter(c)
	return c:IsFaceup() and c:IsNegatable()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetHandler():GetOwner()==tp then
			local sg=Duel.GetMatchingGroupCount(s.tg1setfilter,tp,0,LOCATION_STZONE,nil)
			local ng=Duel.GetMatchingGroupCount(s.tg1negfilter,tp,0,LOCATION_MZONE,nil)
			return sg>0 and ng>0
		else
			return true
		end
	end
	if e:GetHandler():GetOwner()==tp then
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,tp,LOCATION_MZONE)
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
		local sg=Duel.GetMatchingGroupCount(s.tg1setfilter,tp,0,LOCATION_STZONE,nil)
		local ng=Duel.GetMatchingGroup(s.tg1negfilter,tp,0,LOCATION_MZONE,nil)
		if sg==0 or #ng==0 then return end
		local nsg=aux.SelectUnselectGroup(ng,e,tp,1,sg,aux.TRUE,1,tp,HINTMSG_NEGATE)
		for tc in nsg:Iter() do
			tc:NegateEffects(e:GetHandler(),RESET_PHASE+PHASE_END,true)
		end   
	else
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_INACTIVATE)
		e1:SetTargetRange(0,1)
		e1:SetValue(s.op1ofilter)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_DISEFFECT)
		Duel.RegisterEffect(e2,tp)
	end
end

function s.op1ofilter(e,ct)
	local p=e:GetHandler():GetControler()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:GetHandler():IsSetCard(0xf22) and te:GetHandler():IsMonster()
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
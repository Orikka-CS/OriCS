--볼틱갭츠 일렉트로큐션
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

function s.con1filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf37)
end

function s.con1linkfilter(c)
	return c:IsFaceup() and c:IsLinked()
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_ONFIELD,0,c)
	if g==0 then return false end
	if tp==rp or Duel.GetCurrentChain(true)~=0 then return false end
	local lg=Duel.GetMatchingGroup(s.con1linkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #lg==0 then return false end
	local _,max=lg:GetMaxGroup(Card.GetAttack)
	local _,min=lg:GetMinGroup(Card.GetAttack)
	local diff=max-min
	return eg:FilterCount(Card.IsAttackBelow,nil,diff)>0
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local lg=Duel.GetMatchingGroup(s.con1linkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #lg==0 then return false end
	local _,max=lg:GetMaxGroup(Card.GetAttack)
	local _,min=lg:GetMinGroup(Card.GetAttack)
	local diff=max-min
	eg=eg:Filter(Card.IsAttackBelow,nil,diff)
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE+LOCATION_REMOVED)
	if #og>0 then
		local _,atk=og:GetMaxGroup(Card.GetBaseAttack)
		if atk>=0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(0,1)
			e1:SetTarget(s.op1limit)
			e1:SetLabel(atk)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end

function s.op1limit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and c:GetAttack()<=e:GetLabel()
end

--effect 2
function s.con2filter(c)
	return c:IsSetCard(0xf37) and c:GetAttack()>=c:GetBaseAttack()*2 and c:IsFaceup()
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con2filter,tp,LOCATION_MZONE,0,nil)
	return g>0
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsSSetable() then
		Duel.SSet(tp,c)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1)
	end
end
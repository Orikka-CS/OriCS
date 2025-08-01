--나우프라테 디렉터 사무엘
local s,id=GetID()
function s.initial_effect(c)
	--link
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,4,s.linkfilter)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
end

--link
function s.linkfilter(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_LINK,lc,sumtype,tp)
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler() and re:IsActiveType(TYPE_MONSTER)
end

function s.tg1filter(c,e)
	return c:IsFaceup() and c:IsCanTurnSet()
end

function s.tg1ctfilter(c)
	return c:IsSetCard(0xf28) and c:IsMonster()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tg1filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)   
	local ct=Duel.GetMatchingGroupCount(s.tg1ctfilter,tp,LOCATION_GRAVE,0,nil)   
	if chk==0 then return #g>0 and ct>0 end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end

function s.op1filter(c,tp)
	return c:IsTrap() and c:IsControler(tp)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)   
	local ct=Duel.GetMatchingGroupCount(s.tg1ctfilter,tp,LOCATION_GRAVE,0,nil)   
	if #g>0 and ct>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.TRUE,1,tp,HINTMSG_POSCHANGE)
		Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
		sg=sg:Filter(s.op1filter,nil,tp)
		if #sg>0 then
			for tc in aux.Next(sg) do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end

--effect 2
function s.con2filter(c)
	return c:IsTrapMonster() and c:IsContinuousTrap()
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	return c:IsSummonType(SUMMON_TYPE_LINK) and g:FilterCount(s.con2filter,nil)>0
end

function s.tg2(e,c)
	local oc=e:GetHandler()
	return c==oc or oc:GetLinkedGroup():IsContains(c)
end

function s.val2(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
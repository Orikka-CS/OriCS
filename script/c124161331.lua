--스노위퍼 류드밀라 XIII
local s,id=GetID()
function s.initial_effect(c)
	--xyz
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf35),5,3)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.DetachFromSelf(1,1,nil))
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 2
function s.tg1filter(c,e)
	return c:IsAbleToGrave() and c:IsCanBeEffectTarget(e)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and c:IsControler(1-tp) and s.tg1filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_MMZONE+LOCATION_STZONE,nil,e)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,sg,1,0,0)
end

function s.op1filter(c,sq,tsq)
	local seq=c:GetSequence()
	return (seq>sq and tsq>seq) or (seq>tsq and sq>seq ) 
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg then
		local sq=4-c:GetSequence()
		local tsq=tg:GetSequence()
		local g=Duel.GetMatchingGroup(s.op1filter,tp,0,LOCATION_MMZONE+LOCATION_STZONE,nil,sq,tsq)
		Duel.SendtoGrave(g+tg,REASON_EFFECT)
	end
end

--effect 2
function s.con2filter(c,e)
	return c:GetSequence()==0 or c:GetSequence()==4
end

function s.con2(e)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroupCount(s.con2filter,tp,0,LOCATION_ONFIELD,nil)
	return g>0
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsSetCard(0xf35) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetOwnerPlayer()==tp then
		Duel.SetChainLimit(function(e,ep,tp) return ep==tp end)
	end
end
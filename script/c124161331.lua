--스노위퍼 류드밀라 XIII
local s,id=GetID()
function s.initial_effect(c)
	--xyz
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf35),5,2)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
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
function s.tg1filter(c,e,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN) and c:IsCanBeEffectTarget(e)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and c:IsControler(1-tp) and s.tg1filter(chkc,e,tp) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_ONFIELD,nil,e,tp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,1,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e):GetFirst()
	local seq=c:GetSequence()
	local tseq=tg:GetSequence()
	if tg then
		if Duel.Remove(tg,POS_FACEDOWN,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and (seq==0 or seq==4) and seq==tseq then
			Duel.BreakEffect()
			Duel.SetLP(1-tp,Duel.GetLP(1-tp)//2)
		end
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
	if rc:IsSetCard(0xf35) and re:GetOwnerPlayer()==tp then
		Duel.SetChainLimit(function(e,ep,tp) return ep==tp end)
	end
end
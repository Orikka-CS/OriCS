--언엔달 발린 뢰크르트
local s,id=GetID()
function s.initial_effect(c)
	--xyz
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,8,4,s.ovfilter,0,4,s.ovop)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.DetachFromSelf(1,1,nil))
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(s.con2)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
end

--xyz
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(0x3f20) and c:IsControler(tp) and c:GetEquipGroup():IsExists(Card.IsCode,1,nil,124162013)
end
function s.ovop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end

--effect 1
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	local ct=Duel.GetFlagEffect(tp,124162013)
	if chk==0 then return #g>0 and ct>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	local ct=Duel.GetFlagEffect(tp,124162013)
	if #g>0 and ct>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,math.min(ct,#g),aux.TRUE,1,tp,HINTMSG_DESTROY)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end

--effect 2
function s.con2(e)
	return e:GetHandler():GetEquipGroup():IsExists(Card.IsCode,1,nil,124162013)
end
function s.val2(e)
	return math.max(0,Duel.GetFlagEffect(e:GetHandlerPlayer(),124162013)-1)
end

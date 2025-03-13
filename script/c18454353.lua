--하얀 실: 삼위일체
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.con3)
	e3:SetTarget(s.tar3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SPSUMMON_COST)
	e4:SetOperation(s.op4)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.tar5)
	e5:SetOperation(s.op5)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e6:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e6:SetCountLimit(1,{id,2})
	e6:SetCondition(s.con6)
	e6:SetCost(s.cost6)
	e6:SetTarget(s.tar6)
	e6:SetOperation(s.op6)
	c:RegisterEffect(e6)
end
s.listed_names={id}
s.listed_series={0xc01}
function s.val2(e,se,sp,st)
	local sc=se:GetHandler()
	return sc:IsSetCard(0xc01)
end
function s.nfil31(c,sc)
	return c:IsSetCard(0xc01) and c:IsAbleToRemoveAsCost() and (c:IsCanBeSynchroMaterial(sc) or c:IsType(TYPE_SPELL+TYPE_TRAP))
end
function s.nfun3(sg,e,tp,mg)
	local c=e:GetHandler()
	return Duel.GetLocationCountFromEx(tp,tp,sg,c)>0
		and sg:IsExists(s.nfil32,1,nil,sg)
end
function s.nfil32(c,g)
	g:RemoveCard(c)
	local res=c:IsType(TYPE_MONSTER) and g:IsExists(s.nfil33,1,nil,g)
	g:AddCard(c)
	return res
end
function s.nfil33(c,g)
	g:RemoveCard(c)
	local res=c:IsType(TYPE_SPELL) and g:IsExists(Card.IsType,1,nil,TYPE_TRAP)
	g:AddCard(c)
	return res
end
function s.con3(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.nfil31,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,c)
	return aux.SelectUnselectGroup(g,e,tp,3,3,s.nfun3,0)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.nfil31,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,c)
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.nfun3,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else
		return false
	end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then
		return
	end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cre=c:GetReasonEffect()
	if cre and cre:IsHasType(EFFECT_TYPE_ACTIONS) then
		local crc=cre:GetHandler()
		if crc:IsSetCard(0xc01) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT|(RESETS_STANDARD|RESET_DISABLE)&~(RESET_TOFIELD|RESET_LEAVE))
			c:RegisterEffect(e1)
		end
	end
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
			and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0
			and Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)>0
	end
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local g3=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE)
	if #g1>0 and #g2>0 and #g3>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg1=g1:RandomSelect(tp,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg2=g2:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg3=g3:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		sg1:Merge(sg3)
		Duel.HintSelection(sg1)
		Duel.ConfirmCards(tp,sg1)
		local tc1=sg1:GetFirst()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc1:RegisterEffect(e1)
		local tc=sg1:GetFirst()
		while tc do
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(id)
			e2:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SET_AVAILABLE)
			e2:SetDescription(aux.Stringid(id,0))
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			tc=sg1:GetNext()
		end
	end
end
function s.con6(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp~=tp and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.cfil6(c,tp)
	return (c:IsControler(tp) or c:IsHasEffect(18454353))
		and c:IsAbleToRemoveAsCost()
end
function s.cost6(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfil6,tp,LOCATION_HAND,LOCATION_HAND,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.cfil6,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.cfil6,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp)
	end
	local g1=Duel.GetMatchingGroup(s.cfil6,tp,LOCATION_HAND,0,nil,tp)
	local g2=Duel.GetMatchingGroup(s.cfil6,tp,LOCATION_ONFIELD,0,nil,tp)
	local g3=Duel.GetMatchingGroup(s.cfil6,tp,LOCATION_GRAVE,0,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg1=g1:Select(tp,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg2=g2:Select(tp,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg3=g3:Select(tp,1,1,nil)
	sg1:Merge(sg2)
	sg1:Merge(sg3)
	Duel.Remove(sg1,POS_FACEUP,REASON_COST)
end
function s.tar6(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.op6(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
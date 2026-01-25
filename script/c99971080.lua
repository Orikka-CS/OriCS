--[ Stateshifter ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	WriteEff(e1,1,"NTO")
	c:RegisterEffect(e1)
	
end

function s.con1f(c)
	return c:IsFaceup() and c:IsSetCard(0x5d72)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not Duel.IsExistingMatchingCard(s.con1f,tp,LOCATION_MZONE,0,1,nil) then return false end
	return Duel.IsChainNegatable(ev) and (re:IsMonsterEffect() or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.op1f(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN) and c:IsFaceup() and c:IsSetCard(0x5d72)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local rg1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil,tp,POS_FACEDOWN)
		if #rg1<=0 then return end
		local rg2=Duel.GetMatchingGroup(s.op1f,tp,LOCATION_MZONE,0,nil,tp)
		if #rg2<=0 then return end
		local g=aux.SelectUnselectGroup(rg1+rg2,e,tp,2,2,function(sg) return sg:GetClassCount(Card.GetControler)==2 end,1,tp,HINTMSG_REMOVE)
		if #g>0 then
			Duel.HintSelection(g,true)
			Duel.BreakEffect()
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end


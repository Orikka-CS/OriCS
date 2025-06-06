--사령 데스커리버
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"Qo","M")
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetCost(Cost.SelfTribute)
	WriteEff(e1,1,"NTO")
	c:RegisterEffect(e1)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and rp~=tp
		and re:IsMonsterEffect() and Duel.IsChainNegatable(ev) and Duel.GetTurnPlayer()~=tp
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return
	true end
	Duel.SOI(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
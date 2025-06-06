--깨어나지 않는 유령토끼
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","S")
	e2:SetCode(EVENT_CHAINING)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetCountLimit(1,id,EFFETC_COUNT_CODE_CHAIN)
	e2:SetCost(Cost.PayLP(1800))
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsOnField() and (re:IsMonsterEffect()
		or (re:IsSpellTrapEffect() and not re:IsHasType(EFFECT_TYPE_ACTIVATE)))
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then
		return rc:IsDestructable()
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
--달님의 미소
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_CHAINING)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_POSITION+CATEGORY_REMOVE)
	WriteEff(e1,1,"NTO")
	c:RegisterEffect(e1)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return re:IsMonsterEffect() and Duel.IsChainNegatable(ev)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	local rc=re:GetHandler()
	Duel.SOI(0,CATEGORY_NEGATE,eg,1,0,0)
	if rc:IsRelateToEffect(re) then
		if rc:IsLoc("M") and rc:IsCanTurnSet() then
			Duel.SOI(0,CATEGORY_POSITION,eg,1,0,0)
		elseif rc:IsAbleToRemove(POS_FACEDOWN) then
			Duel.SOI(0,CATEGORY_REMOVE,eg,1,0,0)
		end
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		if rc:IsLoc("M") and rc:IsCanTurnSet() then
			Duel.ChangePosition(eg,POS_FACEDOWN_DEFENSE)
		elseif rc:IsAbleToRemove(POS_FACEDOWN) then
			Duel.Remove(eg,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end
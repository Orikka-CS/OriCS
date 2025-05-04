--드랍 드레인
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	WriteEff(e1,1,"C")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FC","S")
	e2:SetCode(EVENT_CHAIN_SOLVING)
	WriteEff(e2,2,"O")
	c:RegisterEffect(e2)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckLPCost(tp,1000)
	end
	Duel.PayLPCost(tp,1000)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local rloc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if not rc:IsRelateToEffect(re) or not rc:IsLoc(rloc) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.NegateEffect(ev)
	end
end
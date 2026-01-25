--[ Stateshifter ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
end

function s.tar1f(c)
	return c:IsSetCard(0x5d72) and c:IsMonster() and c:IsAbleToHand()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tar1f,tp,LOCATION_DECK,0,nil,e,tp)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=3 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tar1f,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=3 then
		local cg=Group.CreateGroup()
		for i=1,3 do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			g:Remove(Card.IsCode,nil,sg:GetFirst():GetCode())
			cg:Merge(sg)
		end
		Duel.ConfirmCards(1-tp,cg)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
		local tc=cg:Select(1-tp,1,1,nil):GetFirst()
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
		cg:RemoveCard(tc)
		Duel.Remove(cg,POS_FACEDOWN,REASON_EFFECT)
	end
end

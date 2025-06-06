--의식의 흐름
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
end
function s.tfil11(c,tp)
	return c:IsRitualMonster() and c:IsAbleToHand()
		and Duel.IEMCard(s.tfil12,tp,"DG",0,1,nil,c)
end
function s.tfil12(c,mc)
	return c:IsRitualSpell() and c:IsAbleToHand() and mc:ListsCode(c:GetCode())
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil11,tp,"D",0,1,nil,tp)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,2,tp,"DG")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil11,tp,"D",0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		local mg=Duel.GMGroup(aux.NecroValleyFilter(s.tfil12),tp,"DG",0,nil,tc)
		if #mg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=mg:Select(tp,1,1,nil)
			g:Merge(sg)
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
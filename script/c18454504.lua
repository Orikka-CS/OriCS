--¾îÂ¼¸é ±×Àú ÀÛÀº »çÈ¸ÀÇ ºñ±Ø
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","G")
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetCost(aux.bfgcost)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
end
s.listed_names={18454503}
function s.cfil1(c)
	return c:IsSetCard("ÃáÇâ") and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.cfil1,tp,"D",0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.cfil1,tp,"D",0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tfil1(c)
	return c:ListsCode(18454503) and c:IsType(TYPE_SPELL) and not c:IsCode(id) and c:IsSSetable()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
function s.tfil2(c)
	return c:ListsCode(18454503) and c:IsType(TYPE_SPELL) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("GR") and chkc:IsControler(tp) and s.tfil2(chkc)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil2,tp,"G",0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.STarget(tp,s.tfil2,tp,"G",0,1,1,nil)
	Duel.SOI(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
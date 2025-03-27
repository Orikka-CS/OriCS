--½ÊÀÌÈñ ¿¡¸Þ·²µåºí·ç
local s,id=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,nil,3,2,s.pfil1,aux.Stringid(id,0),2,s.pop1)
	c:EnableReviveLimit()
	local e1=MakeEff(c,"S","M")
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"I","M")
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetD(id,1)
	e3:SetCL(1)
	WriteEff(e3,3,"CTO")
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
	local e4=MakeEff(c,"I","M")
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e4:SetD(id,2)
	e4:SetCL(1)
	WriteEff(e4,3,"C")
	WriteEff(e4,4,"TO")
	c:RegisterEffect(e4,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.pfil1(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard("½ÊÀÌÈñ") and not c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,id)
end
function s.pop1(e,tp,chk)
	if chk==0 then
		return Duel.GetFlagEffect(tp,id)==0
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end
function s.vfil1(c)
	return c:IsSetCard("½ÊÀÌÈñ") and c:GetAttack()>=0
end
function s.val1(e)
	local ec=e:GetHandler()
	local g=ec:GetOverlayGroup():Filter(s.vfil1,nil)
	return g:GetSum(Card.GetAttack)
end
function s.vfil2(c)
	return c:IsSetCard("½ÊÀÌÈñ") and c:GetDefense()>=0
end
function s.val2(e)
	local ec=e:GetHandler()
	local g=ec:GetOverlayGroup():Filter(s.vfil2,nil)
	return g:GetSum(Card.GetDefense)
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.tfil3(c)
	return c:IsRace(RACE_FAIRY) and c:IsSummonableCard() and c:IsAbleToHand()
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil3,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil3,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("G") and chkc:IsControler(tp) and chkc:IsAbleToDeck()
	end
	if chk==0 then
		return Duel.IETarget(Card.IsAbleToDeck,tp,"G",0,3,nil) and Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.STarget(tp,Card.IsAbleToDeck,tp,"G",0,3,3,nil)
	Duel.SOI(0,CATEGORY_TODECK,g,3,0,0)
	Duel.SOI(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 and Duel.SendtoDeck(g,nil,0,REASON_EFFECT)>0 then
		Duel.ShuffleDeck(tp)
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
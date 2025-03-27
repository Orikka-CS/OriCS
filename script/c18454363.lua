--½ÊÀÌÈñ µå¶õ½ÃÁîÄí
local s,id=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,nil,3,4,s.pfil1,aux.Stringid(id,0),4,s.pop1)
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
	local e3=MakeEff(c,"F","M")
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetTR(0,"M")
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"Qo","M")
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetCL(1)
	e5:SetD(id,1)
	WriteEff(e5,5,"CTO")
	c:RegisterEffect(e5,false,REGISTER_FLAG_DETACH_XMAT)
	local e6=MakeEff(c,"FTo","M")
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e6:SetCL(1)
	WriteEff(e6,6,"TO")
	c:RegisterEffect(e6)
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
function s.val3(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(tp,LSTN("G"),0)*-150
end
function s.cost5(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsOnField()
	end
	if chk==0 then
		return Duel.IETarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.STarget(tp,aux.TRUE,tp,"O","O",1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.tfil6(c)
	return c:IsSetCard("½ÊÀÌÈñ") and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function s.tar6(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil6,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op6(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil3,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
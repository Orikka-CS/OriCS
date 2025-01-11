--프리징 툰드라
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"I","S")
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetCL(1,id)
	WriteEff(e3,3,"NCTO")
	c:RegisterEffect(e3)
end
s.listed_names={15259703}
function s.tfil11(c,tp)
	return c:IsSetCard(0x1062) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
		and not Duel.IEMCard(s.tfil12,tp,"OG",0,1,nil,c:GetCode())
end
function s.tfil12(c,code)
	return c:IsCode(code)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil11,tp,"D",0,1,nil,tp)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil11,tp,"D",0,1,1,nil,tp)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.nfil3(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IEMCard(s.nfil3,tp,"O",0,1,nil)
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToGraveAsCost()
	end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.tfil3(c)
	return c:IsFaceup() and c:IsAttackAbove(1) and c:IsType(TYPE_TOON)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLoc("M") and s.tfil3(chkc)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil3,tp,"M",0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.STarget(tp,s.tfil3,tp,"M",0,1,1,nil)
	local tc=g:GetFirst()
	Duel.SOI(0,CATEGORY_RECOVER,nil,0,tp,tc:GetAttack())
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
	end
end
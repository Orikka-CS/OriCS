--일반마과학
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCategory(CATEGORY_REMOVE)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
end
function s.tfil1(c)
	return ((c:IsOnField() and c:IsType(TYPE_SPELL+TYPE_TRAP)) or c:IsLoc("G")) and c:IsAbleToRemove()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsLoc("OG") and s.tfil1(chkc) and chkc~=c
	end
	if chk==0 then
		return Duel.IETarget(s.tfil1,tp,"OG","OG",1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.STarget(tp,s.tfil1,tp,"OG","OG",1,1,c)
	Duel.SOI(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.ofil1(c)
	return c:IsSetCard("마과학")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	if not Duel.IEMCard(s.ofil1,tp,"O",0,1,exc) and Duel.IEMCard(Card.IsType,tp,0,"HO",1,nil,TYPE_SPELL+TYPE_TRAP)
		and Duel.SelectYesNo(1-tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DESTROY)
		local g=Duel.SMCard(1-tp,Card.IsType,tp,0,"HO",1,1,nil,TYPE_SPELL+TYPE_TRAP)
		Duel.Destroy(g,REASON_EFFECT)
		return
	end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
--½ÊÀÌÈñ ÁöÅ©¸®½º
local s,id=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,nil,3,3,s.pfil1,aux.Stringid(id,0),3,s.pop1)
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
	local e3=MakeEff(c,"STo")
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_REMOVE)
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"I","M")
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCL(1)
	e4:SetD(id,1)
	WriteEff(e4,4,"CTO")
	c:RegisterEffect(e4,false,REGISTER_FLAG_DETACH_XMAT)
	local e5=MakeEff(c,"I","M")
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOGRAVE)
	e5:SetCL(1)
	e5:SetD(id,2)
	WriteEff(e5,5,"TO")
	c:RegisterEffect(e5)
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
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_XYZ)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("M") and chkc:IsAbleToRemove()
	end
	if chk==0 then
		return Duel.IETarget(Card.IsAbleToRemove,tp,"M","M",1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.STarget(tp,Card.IsAbleToRemove,tp,"M","M",1,1,nil)
	Duel.SOI(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(s.ocon31)
		e1:SetOperation(s.oop31)
		e1:SetLabel(Duel.GetTurnCount())
		Duel.RegisterEffect(e1,tp)
	end
end
function s.ocon31(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return Duel.GetTurnCount()>e:GetLabel() and tc:GetFlagEffect(id)~=0
end
function s.oop31(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.ReturnToField(tc)
end
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.tfil41(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.tfil42(c)
	return c:IsSetCard("½ÊÀÌÈñ") and c:IsType(TYPE_MONSTER)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLoc("M") and s.tfil41(chkc)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil41,tp,"M",0,1,nil) and Duel.IEMCard(s.tfil42,tp,"DG",0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.STarget(tp,s.tfil41,tp,"M",0,1,1,nil)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SMCard(tp,s.tfil42,tp,"DG",0,1,1,nil)
		if #g>0 then
			Duel.Overlay(tc,g)
		end
	end
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=c
	end
	if chk==0 then
		return Duel.IETarget(nil,tp,"O",0,1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.STarget(tp,nil,tp,"O",0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:UpdateAttack(1500)==1500 and tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
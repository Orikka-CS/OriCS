--������ ��Ȱ�� �����
local m=18453477
local cm=_G["c"..m]
function cm.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	WriteEff(e1,1,"NO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"A")
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	WriteEff(e2,2,"N")
	WriteEff(e2,1,"O")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"FTf","S")
	e3:SetCode(EVENT_REMOVE)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetD(m,0)
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"FTf","S")
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetD(m,1)
	WriteEff(e4,4,"NTO")
	c:RegisterEffect(e4)
end
function cm.nfil1(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LSTN("G"))
end
function cm.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.nfil1,1,nil,tp)
end
function cm.ofil1(c)
	return c:IsSetCard("���ø�") and c:IsSSetable() and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS)
end
function cm.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then
		return
	end
	if Duel.GetLocCount(tp,"S")<1 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SMCard(tp,cm.ofil1,tp,"D",0,0,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.SSet(tp,tc)
	end
end
function cm.nfil2(c,tp)
	return c:IsControler(1-tp) and c:IsPreviousLocation(LSTN("R")) and c:IsReason(REASON_RETURN)
end
function cm.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.nfil2,1,nil,tp)
end
function cm.nfil3(c)
	return c:IsSetCard("���ø�") and c:IsFaceup() and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and not c:IsCode(m)
end
function cm.con3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IEMCard(cm.nfil3,tp,"O",0,1,nil) and eg:IsExists(cm.nfil1,1,nil,tp)
end
function cm.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=eg:FilterCount(cm.nfil1,nil,tp)
		e:SetLabel(ct)
		return true
	end
	local ct=e:GetLabel()
	Duel.SOI(0,CATEGORY_REMOVE,nil,ct,1-tp,"G")
end
function cm.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then
		return
	end
	if not Duel.IEMCard(cm.nfil3,tp,"O",0,1,nil) then
		return
	end
	local g=Duel.GMGroup(Card.IsAbleToRemove,tp,0,"G",nil)
	local ct=e:GetLabel()
	if ct>#g then
		ct=#g
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:Select(tp,ct,ct,nil)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
function cm.con4(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IEMCard(cm.nfil3,tp,"O",0,1,nil) and eg:IsExists(cm.nfil2,1,nil,tp)
end
function cm.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=eg:FilterCount(cm.nfil2,nil,tp)
		e:SetLabel(ct)
		return true
	end
	local ct=e:GetLabel()
end
function cm.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then
		return
	end
	if not Duel.IEMCard(cm.nfil3,tp,"O",0,1,nil) then
		return
	end
	local g=Duel.GMGroup(aux.TRUE,tp,"R",0,nil)
	local ct=e:GetLabel()
	if ct>#g then
		ct=#g
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:Select(tp,ct,ct,nil)
	Duel.SendtoGrave(sg,nil,REASON_EFFECT+REASON_RETURN)
end
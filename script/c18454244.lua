--功力狼 荐龋鸥玫
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"Qo","HM")
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetCL(1,id)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FTo","M")
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE+CATEGORY_RECOVER)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then
		return false
	end
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)	
end
function s.cfil1(c,ec)
	return c:IsSetCard("功力")
		and ((c:IsAbleToGraveAsCost() and ec:IsAbleToRemoveAsCost())
			or (ec:IsAbleToGraveAsCost() and c:IsAbleToRemoveAsCost()))
		and ((c:IsLoc("H") and ec:IsOnField())
			or (ec:IsLoc("H") and c:IsOnField()))
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GMGroup(s.cfil1,tp,"HO",0,nil,c)
	if chk==0 then
		return #g>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:Select(tp,1,1,nil)
	local tc=sg:GetFirst()
	if c:IsAbleToGraveAsCost() and (not c:IsAbleToRemoveAsCost()
		or not tc:IsAbleToGraveAsCost() or Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
		Duel.SendtoGrave(c,REASON_COST)
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
	else
		Duel.SendtoGrave(tc,REASON_COST)
		Duel.Remove(c,POS_FACEUP,REASON_COST)
	end
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SOI(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) then
		Duel.SPOI(0,CATEGORY_TOGRAVE,eg,1,0,0)
		Duel.SPOI(0,CATEGORY_REMOVE,eg,1,0,0)
	end	
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		if rc:IsAbleToGrave() and (not rc:IsAbleToRemove() or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
			Duel.SendtoGrave(eg,REASON_EFFECT)
		elseif rc:IsAbleToRemove() then
			Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle()
end
function s.tfil2(c,atk)
	return c:GetAttack()<atk and c:IsFaceup() and (c:IsAbleToRemove() or c:IsAbleToGrave())
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local atk=c:GetAttack()
	if chkc then
		return chkc:IsLoc("M") and s.tfil2(chkc,atk)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil2,tp,"M","M",1,nil,atk)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.STarget(tp,s.tfil2,tp,"M","M",1,1,nil,atk)
	local tc=g:GetFirst()
	Duel.SOI(0,CATEGORY_RECOVER,nil,0,tp,tc:GetAttack())
	Duel.SPOI(0,CATEGORY_TOGRAVE,g,1,0,0)
	Duel.SPOI(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local ct=0
		local atk=tc:GetAttack()
		if tc:IsAbleToGrave() and (not tc:IsAbleToRemove() or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
			ct=Duel.SendtoGrave(tc,REASON_EFFECT)
		elseif tc:IsAbleToRemove() then
			ct=Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
		if ct~=0 and atk>0 then
			Duel.Recover(tp,atk,REASON_EFFECT)
		end
	end
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
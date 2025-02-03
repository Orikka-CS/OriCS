--功力狼 父盒利府
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_CHAINING)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","GR")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"CO")
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsSummonType(SUMMON_TYPE_NORMAL) and not tc:IsSummonType(SUMMON_TYPE_TRIBUTE) and tc:GetMaterialCount()==0 then
		tc:RegisterFlagEffect(id-10000,RESET_EVENT+RESETS_STANDARD,0,0)
	end
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.cfil1(c)
	return c:IsLevelAbove(5) and c:IsFaceup() and c:GetFlagEffect(id-10000)~=0
		and c:IsSummonType(SUMMON_TYPE_NORMAL) and not c:IsSummonType(SUMMON_TYPE_TRIBUTE)
		and (c:IsAbleToGraveAsCost() or c:IsAbleToRemoveAsCost())
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.cfil1,tp,"M",0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.cfil1,tp,"M",0,1,1,nil)
	local tc=g:GetFirst()
	local atk=tc:GetAttack()
	if atk<0 then
		atk=0
	end
	e:SetLabel(atk)
	if tc:IsAbleToGraveAsCost() and (not tc:IsAbleToRemoveAsCost() or Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
		Duel.SendtoGrave(tc,REASON_COST)
	else
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
	end
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SOI(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) then
		local atk=e:GetLabel()
		Duel.SPOI(0,CATEGORY_TOGRAVE,eg,1,0,0)
		Duel.SPOI(0,CATEGORY_REMOVE,eg,1,0,0)
		Duel.SOI(0,CATEGORY_RECOVER,nil,0,tp,atk)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		local ct=0
		if rc:IsAbleToGrave() and (not rc:IsAbleToRemove() or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
			ct=Duel.SendtoGrave(eg,REASON_EFFECT)
		elseif rc:IsAbleToRemove() then
			ct=Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
		end
		local atk=e:GetLabel()
		if ct~=0 and atk>0 then
			Duel.BreakEffect()
			Duel.Recover(tp,atk,REASON_EFFECT)
		end
	end
end
function s.cfil2(c,ec)
	return c:IsSetCard("功力") and c:IsFaceup() and not c:IsCode(id)
		and ((c:IsLoc("G") and c:IsAbleToRemoveAsCost() and ec:IsLoc("R"))
			or (ec:IsLoc("G") and ec:IsAbleToRemoveAsCost() and c:IsLoc("R")))
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.cfil2,tp,"GR",0,1,c,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SMCard(tp,s.cfil2,tp,"GR",0,1,1,c,c)
	if c:IsLoc("G") then
		Duel.Remove(c,POS_FACEUP,REASON_COST)
		Duel.SendtoGrave(g,REASON_COST+REASON_RETURN)
	elseif c:IsLoc("R") then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		Duel.SendtoGrave(c,REASON_COST+REASON_RETURN)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_LPCOST_CHANGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTR(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(s.oval21)
	Duel.RegisterEffect(e1,tp)
end
function s.oval21(e,re,rp,val)
	if not re then
		return val
	end
	local rc=re:GetHandler()
	if (rc:IsSetCard("功力") or rc:IsCode(80921533)) and not graish_notcost then
		return val/2
	end
	return val
end
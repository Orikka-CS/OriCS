--크리보졸데
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xa4),2,2)
	local e1=MakeEff(c,"STo")
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCL(1,id)
	WriteEff(e1,1,"NTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","M")
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"STo")
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_RECOVER)
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"F","G")
	e5:SetCode(EFFECT_EXTRA_MATERIAL)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTR(1,0)
	e5:SetValue(s.val5)
	e5:SetOperation(s.op5)
	c:RegisterEffect(e5)
	local e6=MakeEff(c,"SC")
	e6:SetCode(EVENT_BE_MATERIAL)
	e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	WriteEff(e6,6,"NO")
	c:RegisterEffect(e6)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.tfil1(c)
	return c:IsSetCard(0xa4) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.cfil2(c,e,tp)
	return c:IsType(TYPE_QUICKPLAY) and Duel.IEMCard(s.tfil2,tp,"D",0,1,nil,e,tp,c)
end
function s.tfil2(c,e,tp,qc)
	return qc:ListsCode(c:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0xa4)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.cfil2,tp,"D",0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SMCard(tp,s.cfil2,tp,"D",0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"D")
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocCount(tp,"M")<=0 then
		return
	end
	local tc=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SMCard(tp,s.tfil2,tp,"D",0,1,1,nil,e,tp,tc)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.tfil3(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GMGroup(s.tfil3,tp,"MG",0,nil)
	local ct=g:GetClassCount(Card.GetAttribute)
	if chk==0 then
		return ct>0
	end
	Duel.SOI(0,CATEGORY_RECOVER,nil,0,tp,ct*300)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GMGroup(s.tfil3,tp,"MG",0,nil)
	local ct=g:GetClassCount(Card.GetAttribute)
	if ct>0 then
		Duel.Recover(tp,ct*300,REASON_EFFECT)
	end
end
function s.op5(c,e,tp,sg,mg,lc,og,chk)
	return true
end
function s.val5(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not c:IsAbleToRemove() then
			return Group.CreateGroup()
		else
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK then
		end
	elseif chk==2 then
	end
end
function s.con6(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
function s.op6(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=MakeEff(c,"S")
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetD(id,0)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	e2:SetValue(s.oval62)
	rc:RegisterEffect(e2,true)
end
function s.oval62(e,te)
	return te:IsActiveType(TYPE_MONSTER) and e:GetHandler()~=te:GetOwner()
end
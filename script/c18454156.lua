--윙크리보
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"I","H")
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCL(1,id)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"STo")
	e4:SetCode(EVENT_RELEASE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetCL(1,{id,2})
	WriteEff(e4,4,"TO")
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e5)
	local e6=MakeEff(c,"F","G")
	e6:SetCode(EFFECT_EXTRA_MATERIAL)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTR(1,0)
	e6:SetValue(s.val6)
	e6:SetOperation(s.op6)
	c:RegisterEffect(e6)
	local e7=MakeEff(c,"SC")
	e7:SetCode(EVENT_BE_MATERIAL)
	e7:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	WriteEff(e7,7,"NO")
	c:RegisterEffect(e7)
end
s.listed_names={25573054}
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsDiscardable()
	end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.tfil1(c,e,tp)
	return c:IsSetCard(0xa4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsFaceup() and not c:IsCode(id)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("GR") and chkc:IsControler(tp) and s.tfil1(chkc,e,tp)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil1,tp,"GR",0,1,nil,e,tp) and Duel.GetLocCount(tp,"M")>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.STarget(tp,s.tfil1,tp,"GR",0,1,1,nil,e,tp)
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.tfil2(c)
	return c:IsSetCard(0xa4) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil2,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil2,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.tfil4(c)
	return c:IsCode(25573054) and c:IsAbleToHand()
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil4,tp,"DG",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"DG")
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,aux.NecroValleyFilter(s.tfil4),tp,"DG",0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.op6(c,e,tp,sg,mg,lc,og,chk)
	return true
end
function s.val6(chk,summon_type,e,...)
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
function s.con7(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
function s.op7(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=MakeEff(c,"S")
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetD(id,0)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	local e2=MakeEff(c,"FC","M")
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	e2:SetOperation(s.oop72)
	rc:RegisterEffect(e2,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e3=MakeEff(c,"S")
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
end
function s.oop72(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(id)==0 then
		if rp~=tp and re:IsActiveType(TYPE_SPELL) and Duel.IsChainDisablable(ev) then
			if Duel.NegateEffect(ev) then
				Duel.Destroy(eg,REASON_EFFECT)
				Duel.Hint(HINT_CARD,1-tp,id)
				c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
			end
		end
	end
end
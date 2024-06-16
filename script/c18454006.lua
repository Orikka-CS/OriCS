--어나더 레벨: 리바이어던
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"FTo","H")
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e1:SetCL(1,id)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","M")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"NCTO")
	c:RegisterEffect(e2)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:IsPublic()
	end
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return true
	end
	Duel.SPOI(0,CATEGORY_RECOVER,nil,0,tp,3750)
	Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SPOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.ofil11(c,tp)
	return c:IsRace(RACE_REPTILE) and c:IsControler(tp)
end
function s.ofil12(c)
	return c:IsCode(id) and c:IsAbleToHand()
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local turn_ct=Duel.GetTurnCount()
	local curr_phase=Duel.GetCurrentPhase()
	local skip_next_turn=(Duel.IsTurnPlayer(tp) and curr_phase>=PHASE_MAIN1)
	local reset_ct=skip_next_turn and 2 or 1
	local e1=MakeEff(c,"F")
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_M1)
	e1:SetTR(1,0)
	if skip_next_turn then
		e1:SetCondition(function() return Duel.GetTurnCount()~=turn_ct end)
	end
	e1:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN,reset_ct)
	Duel.RegisterEffect(e1,tp)
	local b1=true
	local b2=Duel.GetLocCount(tp,"M")>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,18454013,0x0,0x4011,3750,2750,10,RACE_REPTILE,ATTRIBUTE_WATER)
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	if op==1 then
		Duel.Recover(tp,3750,REASON_EFFECT)
	elseif op==2 then
		local token=Duel.CreateToken(tp,18454013)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	else
		return
	end
	if not c:IsRelateToEffect(e) then
		return
	end
	Duel.BreakEffect()
	local b3=c:IsDiscardable()
	local b4=c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.CheckReleaseGroup(tp,s.ofil11,2,false,2,true,c,tp,nil,nil,nil,tp)
	op=Duel.SelectEffect(tp,
		{b3,aux.Stringid(id,2)},
		{b4,aux.Stringid(id,3)})
	if op==1 then
		Duel.SendtoGrave(c,REASON_EFFECT+REASON_DISCARD)
	elseif op==2 then
		local g=Duel.SelectReleaseGroup(tp,s.ofil11,2,2,false,true,true,c,nil,nil,false,nil,tp)
		Duel.Release(g,REASON_EFFECT)
		if Duel.GetLocCount(tp,"M")>0 then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.ofil12,tp,"D",0,0,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.CheckEvent(EVENT_SUMMON_SUCCESS) and not Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemoveAsCost()
	end
	if Duel.Remove(c,POS_FACEUP,REASON_COST+REASON_TEMPORARY)~=0 then
		local ct=1
		local e1=MakeEff(c,"FC")
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		if Duel.GetCurrentPhase()==PHASE_STANDBY then
			ct=2
			e1:SetLabel(Duel.GetTurnCount())
		else
			e1:SetLabel(0)
		end
		e1:SetReset(RESET_PHASE+PHASE_STANDBY,ct)
		e1:SetLabelObject(c)
		e1:SetCL(1)
		e1:SetCondition(s.ccon21)
		e1:SetOperation(s.cop21)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.ccon21(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetLabel()
end
function s.cop21(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
function s.tfil2(c)
	return c:IsSummonLocation(LSTN("E")) and c:IsAbleToRemove()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GMGroup(s.tfil2,tp,"M","M",nil)
	if chk==0 then
		return #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GMGroup(Card.IsSummonLocation,tp,"M","M",nil,LSTN("E"))
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT,LSTN("R"))
		local tc=g:GetFirst()
		while tc do
			if tc:IsLoc("R") and tc:GetReasonEffect()==e then
				local e1=MakeEff(c,"F")
				e1:SetCode(EFFECT_DISABLE)
				e1:SetTR("M","M")
				e1:SetTarget(s.otar21)
				e1:SetLabel(tc:GetOriginalCodeRule())
				e1:SetReset(RESET_PHASE+PHASE_END,2)
				Duel.RegisterEffect(e1,tp)
				local e2=MakeEff(c,"FC")
				e2:SetCode(EVENT_CHAIN_SOLVING)
				e2:SetCondition(s.ocon22)
				e2:SetOperation(s.oop22)
				e2:SetLabel(tc:GetOriginalCodeRule())
				e2:SetReset(RESET_PHASE+PHASE_END,2)
				Duel.RegisterEffect(e2,tp)
			end
			tc=g:GetNext()
		end
	end
end
function s.otar21(e,c)
	local code=e:GetLabel()
	local code1,code2=c:GetOriginalCodeRule()
	return code1==code or code2==code
end
function s.ocon22(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	local code1,code2=re:GetHandler():GetOriginalCodeRule()
	return re:IsActiveType(TYPE_MONSTER) and (code1==code or code2==code)
end
function s.oop22(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateEffect(ev)
end

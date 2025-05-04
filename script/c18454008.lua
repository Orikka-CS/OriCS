--어나더 레벨: 유니버설웜
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"FTo","H")
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e1:SetCL(1,id)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","M")
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"NTO")
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
	local b3=true
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
	local trig_loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return not Duel.CheckEvent(EVENT_SUMMON_SUCCESS) and not Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS)
		and rp~=tp and trig_loc&LSTN("O")>0
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IETarget(Card.IsNegatable,tp,0,"O",1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.STarget(tp,Card.IsNegatable,tp,0,"O",1,1,nil)
	Duel.SOI(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and not tc:IsDisabled() and tc:IsRelateToEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
	end
end
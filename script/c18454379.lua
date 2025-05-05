--퓨어블러드 칼리
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"Qo","HG")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STf")
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCategory(CATEGORY_TOHAND)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"STo")
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_SEARCH)
	WriteEff(e3,2,"C")
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
end
s.phase_table={PHASE_DRAW,PHASE_STANDBY,PHASE_MAIN1,PHASE_BATTLE,PHASE_MAIN2,PHASE_END}
function s.phase_function(phase)
	if phase>PHASE_MAIN1 and phase<PHASE_MAIN2 then
		phase=PHASE_BATTLE
	end
	return phase
end
function s.phase_check(phase)
	local ph=Duel.GetCurrentPhase()
	if phase==PHASE_BATTLE then
		return ph>PHASE_MAIN1 and ph<PHASE_MAIN2
	end
	return ph==phase
end
function s.next_phase(phase)
	local index=0
	local next_phase=0
	for i=1,6 do
		if phase==s.phase_table[i] then
			index=i
			break
		end
	end
	if index==6 then
		next_phase=s.phase_table[1]
	elseif index==3 and not Duel.IsAbleToEnterBP() then
		next_phase=PHASE_END
	else
		next_phase=s.phase_table[index+1]
	end
	return next_phase
end
function s.cfil1(c)
	return c:IsAbleToRemoveAsCost() and (c:IsRace(RACE_FAIRY) or c:IsAttribute(ATTRIBUTE_LIGHT))
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.cfil1,tp,"HG",0,2,c) and Duel.GetFlagEffect(tp,id)==0
	end
	local phase=s.phase_function(Duel.GetCurrentPhase())
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+phase,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SMCard(tp,s.cfil1,tp,"HG",0,2,2,c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.tfil1(c,e,tp)
	return c:IsCode(18454377) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0 and Duel.IEMCard(s.tfil1,tp,"HG",0,1,nil,e,tp)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"HG")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local phase=s.phase_function(Duel.GetCurrentPhase())
	local next_phase=s.next_phase(phase)
	local e1=MakeEff(c,"FC")
	e1:SetCode(EVENT_PURE_BLOOD)
	e1:SetReset(RESET_PHASE+next_phase)
	e1:SetLabel(next_phase)
	e1:SetCondition(s.ocon11)
	e1:SetOperation(s.oop11)
	Duel.RegisterEffect(e1,tp)
	if phase==PHASE_MAIN1 and next_phase==PHASE_BATTLE then
		local e2=e1:Clone()
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetLabel(PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.ocon11(e,tp,eg,ep,ev,re,r,rp)
	local phase=e:GetLabel()
	local current_phase=s.phase_function(Duel.GetCurrentPhase())
	if (current_phase==PHASE_END and phase==PHASE_BATTLE)
		or (current_phase==PHASE_BATTLE and phase==PHASE_END) then
		e:Reset()
	end
	return s.phase_check(phase) and Duel.GetLocCount(tp,"M")>0
		and Duel.IEMCard(aux.NecroValleyFilter(s.tfil1),tp,"HG",0,1,nil,e,tp)
end
function s.oop11(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SMCard(tp,aux.NecroValleyFilter(s.tfil1),tp,"HG",0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	e:Reset()
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFlagEffect(tp,id)==0
	end
	local phase=s.phase_function(Duel.GetCurrentPhase())
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+phase,0,1)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SPOI(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,"OGR")
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local phase=s.phase_function(Duel.GetCurrentPhase())
	local next_phase=s.next_phase(phase)
	local e1=MakeEff(c,"FC")
	e1:SetCode(EVENT_ANYTIME)
	e1:SetReset(RESET_PHASE+next_phase)
	e1:SetLabel(next_phase)
	e1:SetCondition(s.ocon21)
	e1:SetOperation(s.oop21)
	Duel.RegisterEffect(e1,tp)
	if phase==PHASE_MAIN1 and next_phase==PHASE_BATTLE then
		local e2=e1:Clone()
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetLabel(PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
	if c:IsRelateToEffect(e) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
		local e3=MakeEff(c,"FC")
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCL(1)
		e3:SetReset(RESET_PHASE+PHASE_END,2)
		e3:SetLabel(Duel.GetTurnCount())
		e3:SetCondition(s.ocon23)
		e3:SetOperation(s.oop23)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.ocon21(e,tp,eg,ep,ev,re,r,rp)
	local phase=e:GetLabel()
	local current_phase=s.phase_function(Duel.GetCurrentPhase())
	if (current_phase==PHASE_END and phase==PHASE_BATTLE)
		or (current_phase==PHASE_BATTLE and phase==PHASE_END) then
		e:Reset()
	end
	return s.phase_check(phase) and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsAbleToHand),
		tp,LSTN("OGR"),LSTN("OGR"),1,nil)
end
function s.oop21(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToHand),
		tp,LSTN("OGR"),LSTN("OGR"),1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
	e:Reset()
end
function s.ocon23(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(id)==0 then
		e:Reset()
		return false
	end
	return Duel.GetTurnCount()~=e:GetLabel()
end
function s.oop23(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.HintSelection(Group.FromCards(c))
	Duel.SendtoHand(c,nil,REASON_EFFECT)
end
function s.tfil3(c,e,tp)
	return (c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)) and c:IsAbleToHand()
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil3,tp,"D",0,1,nil)
	end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local phase=s.phase_function(Duel.GetCurrentPhase())
	local next_phase=s.next_phase(phase)
	local e1=MakeEff(c,"FC")
	e1:SetCode(EVENT_PURE_BLOOD)
	e1:SetReset(RESET_PHASE+next_phase)
	e1:SetLabel(next_phase)
	e1:SetCondition(s.ocon31)
	e1:SetOperation(s.oop31)
	Duel.RegisterEffect(e1,tp)
	if phase==PHASE_MAIN1 and next_phase==PHASE_BATTLE then
		local e2=e1:Clone()
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetLabel(PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.ocon31(e,tp,eg,ep,ev,re,r,rp)
	local phase=e:GetLabel()
	local current_phase=s.phase_function(Duel.GetCurrentPhase())
	if (current_phase==PHASE_END and phase==PHASE_BATTLE)
		or (current_phase==PHASE_BATTLE and phase==PHASE_END) then
		e:Reset()
	end
	return s.phase_check(phase) and Duel.IEMCard(s.tfil3,tp,"D",0,1,nil)
end
function s.oop31(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil3,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	e:Reset()
end
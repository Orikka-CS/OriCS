--퓨어블러드 티아라
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"Qo","H")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
end
s.listed_names={18454383}
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
	return c:IsDiscardable() and (c:IsRace(RACE_FAIRY) or c:IsAttribute(ATTRIBUTE_WATER))
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsDiscardable() and Duel.IEMCard(s.cfil1,tp,"H",0,1,c)
			and Duel.GetFlagEffect(tp,id)==0
	end
	local phase=s.phase_function(Duel.GetCurrentPhase())
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+phase,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SMCard(tp,s.cfil1,tp,"H",0,1,1,c)
	g:AddCard(c)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
function s.tfil1(c,e,tp)
	return c:IsCode(18454383) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0 and Duel.IEMCard(s.tfil1,tp,"D",0,1,nil,e,tp)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"D")
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
	return s.phase_check(phase) and Duel.GetLocCount(tp,"M")>0 and Duel.IEMCard(s.tfil1,tp,"D",0,1,nil,e,tp)
end
function s.oop11(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	e:Reset()
	if Duel.GetCurrentChain()>0 then
		Duel.ProcessQuickEffect(1-tp)
	end
end
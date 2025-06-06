--시간의 여신의 진심
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ph=Duel.GetCurrentPhase()
	local turnp=Duel.GetTurnPlayer()
	if ph<=PHASE_DRAW then
		Duel.SkipPhase(turnp,PHASE_DRAW,RESET_PHASE|PHASE_END,1)
	end
	if ph<=PHASE_STANDBY then
		Duel.SkipPhase(turnp,PHASE_STANDBY,RESET_PHASE|PHASE_END,1)
	end
	if ph<=PHASE_MAIN1 then
		Duel.SkipPhase(turnp,PHASE_MAIN1,RESET_PHASE|PHASE_END,1)
	end
	if ph<=PHASE_BATTLE then
		Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE|PHASE_END,1)
	end
	if ph<=PHASE_MAIN2 then
		Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE|PHASE_END,1)
	end
	if ph<=PHASE_END then
		Duel.SkipPhase(turnp,PHASE_END,RESET_PHASE|PHASE_END,1)
	end
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_SKIP_TURN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTR(1,1)
	e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BP)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_EP)
	Duel.RegisterEffect(e3,tp)
end
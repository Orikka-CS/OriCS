--[ Colossus ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	WriteEff(e2,2,"NO")
	c:RegisterEffect(e2)
	
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3d6f))
	c:RegisterEffect(e3)
	
	local e4=MakeEff(c,"FTo","S")
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCL(1)
	WriteEff(e4,4,"NTO")
	c:RegisterEffect(e4)
	
end

function s.con2fil(c,tp)
	return c:GetSummonPlayer()==tp and c:IsFaceup() and c:IsSetCard(0x3d6f)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.con2fil,1,nil,tp)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local hand_limit=Duel.GetHandLimit(tp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local e1=MakeEff(c,"F")
		e1:SetCode(EFFECT_HAND_LIMIT)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTR(1,0)
		e1:SetValue(hand_limit)
		Duel.RegisterEffect(e1,tp)
		local e2=MakeEff(c,"F")
		e2:SetCode(EFFECT_UPDATE_HAND_LIMIT)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetTR(1,0)
		e2:SetValue(3)
		Duel.RegisterEffect(e2,tp)
	end
end

function s.con4(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_ADJUST)~=0
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_GRAVE)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetCurrentPhase()==PHASE_STANDBY and 2 or 1
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(s.op4con)
	e1:SetOperation(s.op4op)
	e1:SetLabel(ct,Duel.GetTurnCount())
	e1:SetReset(RESET_PHASE+PHASE_STANDBY,ct)
	Duel.RegisterEffect(e1,tp)
end
function s.op4con(e,tp,eg,ep,ev,re,r,rp)
	local sp_label,turn=e:GetLabel()
	return (sp_label==1 or turn~=Duel.GetTurnCount()) and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,nil)
end
function s.op4op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local sg=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,nil)
	if #sg==0 then return end
	local rg=sg:Select(tp,1,1,nil)
	Duel.SendtoHand(rg:GetFirst(),nil,REASON_EFFECT)
	e:Reset()
end

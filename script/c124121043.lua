--트리아드나 하르카나
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tar2)
	e2:SetValue(ATTRIBUTE_EARTH)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.con3)
	e3:SetTarget(s.tar3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={87979586}
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	if ph&(PHASE_MAIN1+PHASE_MAIN2)>0 then
		for tc in aux.Next(eg) do
			tc:RegisterFlagEffect(id,RESET_PHASE+ph,0,1)
		end
	end
end
function s.tfil1(c,e,tp)
	return c:IsAbleToHand() and c:IsCode(87979586)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tfil1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.nfil2(c)
	return c:IsFaceup() and c:IsCode(87979586)
end
function s.con2(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.nfil2,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.tar2(e,c)
	return c:GetFlagEffect(id)>0
end
function s.nfil3(c,tp)
	local code1,code2=c:GetPreviousCodeOnField()
	return c:IsPreviousControler(tp)
		and c:IsPreviousPosition(POS_FACEUP)
		and (code1==87979586 or code2==87979586)
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.nfil3,1,nil,tp)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(s.ocon31)
	e1:SetOperation(s.oop31)
	Duel.RegisterEffect(e1,tp)
end
function s.onfil31(c)
	return c:IsCanTurnSet() and not c:IsAttribute(ATTRIBUTE_EARTH)
end
function s.ocon31(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.onfil31,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	return #g>0
end
function s.oop31(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.onfil31,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end
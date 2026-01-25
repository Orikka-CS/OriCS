--[ Stateshifter ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"Qo","MG")
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCL(1,id)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
	
	local e3=MakeEff(c,"FC","R")
	e3:SetCode(EVENT_ADJUST)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	WriteEff(e3,3,"NO")
	c:RegisterEffect(e3)
	
	aux.GlobalCheck(s,function()
		s[0]=0
		aux.AddValuesReset(function()
			s[0]=0
		end)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e4:SetCode(EVENT_CHAINING)
		e4:SetOperation(s.checkop)
		Duel.RegisterEffect(e4,0)
	end)
	
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local temp=re:GetActiveType()&0x7
	local p=e:GetHandlerPlayer()
	if rp~=p and s[0]==TYPE_TRAP and temp==TYPE_MONSTER then
		Duel.RegisterFlagEffect(p,id,RESET_PHASE|PHASE_END,0,1)
	end
	s[0]=temp
end

function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost(POS_FACEDOWN) end
	Duel.Remove(c,POS_FACEDOWN,REASON_COST)
end
function s.tar2f(c)
	return c:IsSetCard(0x5d72) and c:IsAbleToHand()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar2f,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tar2f,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.con3(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummon(tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsFacedown()
		and (not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,id),tp,LOCATION_ONFIELD,0,1,nil))
		and Duel.HasFlagEffect(tp,id,1)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if (not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,id),tp,LOCATION_ONFIELD,0,1,nil))
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.ResetFlagEffect(tp,id)
		local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			local hg=g:Select(tp,1,1,nil)
			Duel.HintSelection(hg,true)
			Duel.BreakEffect()
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
		end
	end
end

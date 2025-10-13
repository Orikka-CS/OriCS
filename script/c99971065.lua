--[ N Corp. Fanatic ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,te) return te:GetOwner():IsRace(RACE_MACHINE) or te:GetOwner():GetCounter(0x1d72)>0 end)
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	
	local e3=MakeEff(c,"Qo","M")
	e3:SetCategory(CATEGORY_COUNTER+CATEGORY_DESTROY+CATEGORY_DISABLE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCL(2)
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
	
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	for i=1,ev do
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		if tgp==tp and te:GetHandler():IsSetCard(0x3d72) then
			return true
		end
	end
	return false
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetCurrentChain(true)>1 end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLocation(LOCATION_HAND) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3d72))
	e1:SetValue(1000)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local sinclair=Duel.GetFirstMatchingCard(aux.FaceupFilter(Card.IsCode,99971066),tp,LOCATION_MZONE,0,nil)
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_HAND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		if sinclair then
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(aux.Stringid(id,2))
			e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetDescription(aux.Stringid(99971066,2))
			e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetReset(RESETS_STANDARD_PHASE_END)
			sinclair:RegisterEffect(e3)
		end
	end
end

function s.tar3f(c)
	return c:IsCanAddCounter(0x1d72,3) and c:IsRace(RACE_MACHINE)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnfield() and s.tar3f(chkc) and chkc:IsControler(1-tp) end 
	if chk==0 then return Duel.IsExistingTarget(s.tar3f,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.tar3f,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0x1d72,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:AddCounter(0x1d72,3) and tc:GetCounter(0x1d72)>4 then
		if tc:IsRelateToEffect(e) and tc:IsNegatable() and tc:IsCanBeDisabledByEffect(e) then
			tc:NegateEffects(e:GetHandler())
			Duel.AdjustInstantly(tc)
			if tc:IsDisabled() then
				Duel.Destroy(tc,REASON_EFFECT)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(aux.Stringid(id,1))
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetReset(RESETS_STANDARD_PHASE_END)
				e:GetHandler():RegisterEffect(e1)
			end
		end
	end
end

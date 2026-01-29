--콘트라기온 마기아 칼레라
local s,id=GetID()
function s.initial_effect(c)
	--synchro
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not eg:IsContains(c)
end

function s.tg1filter1(c)
	return c:IsSetCard(0xf39) and c:IsSpell() and c:IsAbleToHand()
end

function s.tg1filter2(c)
	return c:IsFaceup() and c:HasLevel() and not c:IsLevel(3)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.tg1filter1,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.tg1filter2,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	local b=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	e:SetLabel(b)
	if b==1 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(0)
	end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local b=e:GetLabel()
	if b==1 then
		local g=Duel.GetMatchingGroup(s.tg1filter1,tp,LOCATION_DECK,0,nil)
		if #g>0 then
			local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	elseif b==2 then
		local g=Duel.GetMatchingGroup(s.tg1filter2,tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_FACEUP)
			local tc=sg:GetFirst()
			if tc then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetValue(3)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end

--effect 2
function s.con2filter(c)
	return c:IsFaceup() and c:IsCode(124161384)
end

function s.con2(e)
	return Duel.GetMatchingGroupCount(s.con2filter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)>0
end

function s.tg2(e,c)
	return c:IsFaceup() and c:IsSetCard(0xf39)
end

function s.val2(e,te)
	return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActiveType(TYPE_MONSTER) and te:GetHandler():IsType(TYPE_TUNER)
end
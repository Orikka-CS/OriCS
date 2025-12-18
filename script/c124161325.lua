--스노위퍼 카를로
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetValue(function() return 0,0x11 end)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

function s.tg2filter(c)
	return c:IsSetCard(0xf35) and not c:IsCode(id) and c:IsMonster() and c:IsAbleToHand()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.op2ctfilter(c)
	return c:IsSetCard(0xf35) and c:IsFaceup() and (c:GetSequence()==0 or c:GetSequence()==4)
end

function s.op2filter(c)
	return c:IsNegatable() and c:IsType(TYPE_EFFECT) and c:IsFaceup()
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		local ct=Duel.GetMatchingGroupCount(s.op2ctfilter,tp,LOCATION_MZONE,0,nil)
		local mg=Duel.GetMatchingGroup(s.op2filter,tp,0,LOCATION_MZONE,nil)
		if ct>0 and #mg>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local msg=aux.SelectUnselectGroup(mg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_NEGATE):GetFirst()
			msg:NegateEffects(e:GetHandler(),nil)
			Duel.MoveSequence(msg,math.log(Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)>>16,2))
		end
	end
end
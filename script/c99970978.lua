--[ ChaoticWing ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xcd70))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SEARCH_CARD+CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	WriteEff(e4,4,"NTO")
	c:RegisterEffect(e4)
	
	local e99=MakeEff(c,"FC","S")
	e99:SetCode(EVENT_DESTROYED)
	e99:SetOperation(s.op99)
	c:RegisterEffect(e99)
	local e100=e99:Clone()
	e100:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e100)
	
	
	aux.GlobalCheck(s,function()
		s[0]=0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetCondition(s.regcon)
		e1:SetOperation(s.regop1)
		Duel.RegisterEffect(e1,0)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_NEGATED)
		e2:SetCondition(s.regcon)
		e2:SetOperation(s.regop2)
		Duel.RegisterEffect(e2,0)
		aux.AddValuesReset(function()
			s[0]=0
		end)
	end)
end

function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.regop1(e,tp,eg,ep,ev,re,r,rp)
	s[0]=s[0]+1
end
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	if s[0]>0 then
		s[0]=s[0]-1
	end
end
function s.atkval(e,c)
	return s[0]*200
end

function s.op99(e,tp,eg,ep,ev,re,r,rp)
	if not re or not re:IsActivated() or rp~=tp 
		or not re:GetHandler():IsCode(CARD_CYCLONE,CARD_CYCLONE_GALAXY,CARD_CYCLONE_COSMIC,CARD_CYCLONE_DOUBLE,CARD_CYCLONE_DICE) then return end
	Duel.BreakEffect()
	local g=eg:Filter(Card.IsControler,nil,1-tp)
	local c=e:GetHandler()
	for tc in g:Iter() do
		local code=tc:GetOriginalCodeRule()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetTargetRange(0,LOCATION_ONFIELD)
		e1:SetLabel(code)
		e1:SetTarget(s.distg)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetLabel(code)
		e2:SetCondition(s.discon)
		e2:SetOperation(s.disop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		e3:SetTargetRange(0,LOCATION_MZONE)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.distg(e,c)
	return c:IsOriginalCodeRule(e:GetLabel())
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsOriginalCodeRule(e:GetLabel()) and rp~=tp
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

function s.con4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_DECK)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
function s.op4fil(c)
	return c:IsSetCard(0xcd70) and c:IsAbleToHand()
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if Duel.SendtoDeck(c,nil,0,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK) then
			local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.op4fil),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local sg=g:Select(tp,1,1,nil)
				Duel.BreakEffect()
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
end


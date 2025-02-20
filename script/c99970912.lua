--[ Trie Elow ]
local s,id=GetID()
function s.initial_effect(c)

	c:EnableCounterPermit(COUNTER_SPELL)
	
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
	
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_HAND,0)
	e4:SetCondition(s.handcon)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x9d6f))
	e4:SetCountLimit(1,{id,1})
	e4:SetValue(function(e,rc,re) re:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,0,e:GetHandler():GetFieldID()) end)
	c:RegisterEffect(e4)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_ACTIVATE_COST)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(1,0)
	e5:SetTarget(s.costtg)
	e5:SetOperation(s.costop)
	c:RegisterEffect(e5)
	
end

s.counter_place_list={COUNTER_SPELL}

function s.tar1fil(c)
	return c:IsSetCard(0x9d6f) and c:IsAbleToHand()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar1fil,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tar1fil,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		if c:IsFaceup() and c:IsCanAddCounter(COUNTER_SPELL,1) then
			Duel.BreakEffect()
			c:AddCounter(COUNTER_SPELL,1)
		end
	end
end

function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	return e:GetHandler():IsCanRemoveCounter(tp,COUNTER_SPELL,3,REASON_COST)
end
function s.costtg(e,te,tp)
	local tc=te:GetHandler()
	return tc:IsLocation(LOCATION_HAND) and tc:HasFlagEffect(id) and tc:GetFlagEffectLabel(id)==e:GetHandler():GetFieldID()
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	e:GetHandler():RemoveCounter(tp,COUNTER_SPELL,3,REASON_COST)
end

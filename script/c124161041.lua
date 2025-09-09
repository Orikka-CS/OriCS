--이클립스 엄브라레
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf22) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(s.tg3)
	c:RegisterEffect(e3)
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD)
	e3a:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3a:SetRange(LOCATION_FZONE)
	e3a:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3a:SetTargetRange(LOCATION_MZONE,0)
	e3a:SetTarget(s.tg3)
	e3a:SetValue(aux.tgoval)
	c:RegisterEffect(e3a)
end

--effect 1
function s.val1(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFacedown,e:GetHandlerPlayer(),0,LOCATION_STZONE,nil)*300
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():GetOwner()==tp and re:GetHandler():IsSetCard(0xf22) and re:GetHandler()~=e:GetHandler()
end

function s.tg2filter(c,cd)
	return c:IsSetCard(0xf22) and c:IsAbleToHand() and not c:IsType(TYPE_FIELD) and not c:IsCode(cd) 
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,ep,1,1,aux.TRUE,1,ep,HINTMSG_TOGRAVE):GetFirst()
		Duel.SendtoGrave(sg,REASON_EFFECT)
		local hg=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_GRAVE,0,nil,re:GetHandler():GetCode())
		if sg:IsLocation(LOCATION_GRAVE) and #hg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local hsg=aux.SelectUnselectGroup(hg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
			Duel.SendtoHand(hsg,nil,REASON_EFFECT)
		end
	end
end

--effect 3
function s.tg3filter(c,tp)
	return c:IsFacedown() and c:IsLocation(LOCATION_SZONE) and c:IsControler(1-tp) 
end

function s.tg3(e,c)
	return c:IsSetCard(0xf22) and c:GetColumnGroup():IsExists(s.tg3filter,1,nil,e:GetHandlerPlayer()) and c:IsFaceup()
end
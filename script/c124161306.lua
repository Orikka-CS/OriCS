--시데르파그의 상흔
local s,id=GetID()
function s.initial_effect(c)
	--activate
	aux.AddEquipProcedure(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_EQUIP)
	e1a:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1a:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1a:SetValue(aux.tgoval)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SET_CONTROL)
	e2:SetValue(function(e) return e:GetHandlerPlayer() end)
	e2:SetCondition(s.con2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCost(Cost.SelfToDeck)
	e3:SetTarget(s.tg3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end

--effect 1
function s.val1filter(c)
	return c:IsSetCard(0xf33) and c:IsFaceup()
end

function s.val1(e)
	return Duel.GetMatchingGroupCount(s.val1filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*500
end

--effect 2
function s.con2filter(c)
	return c:IsSetCard(0xf33) and c:IsFaceup()
end

function s.con2(e)
	return Duel.GetMatchingGroupCount(s.con2filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)>0
end

--effect 3
function s.tg3filter(c)
	return c:IsSetCard(0xf33) and c:IsMonster() and c:IsAbleToHand() 
end

function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg3filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_DECK)
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg3filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
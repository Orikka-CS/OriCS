--[ Plague ]
local s,id=GetID()
function s.initial_effect(c)

	local e9=Effect.CreateEffect(c)
	e9:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e9:SetType(EFFECT_TYPE_ACTIVATE)
	e9:SetCode(EVENT_FREE_CHAIN)
	e9:SetOperation(s.activate)
	c:RegisterEffect(e9)
	
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetCode(CARD_PESTILENCE)
	e8:SetRange(LOCATION_FZONE)
	e8:SetTargetRange(1,1)
	c:RegisterEffect(e8)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ACTIVATE_COST)
	e1:SetRange(LOCATION_FZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(s.actarget)
	e1:SetCost(s.costchk)
	e1:SetOperation(s.costop)
	c:RegisterEffect(e1)
	
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e4:SetTarget(s.tar)
	e4:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
	c:RegisterEffect(e4)
	
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(id)
	e7:SetRange(LOCATION_FZONE)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetTargetRange(1,1)
	c:RegisterEffect(e7)
	
end

function s.thfilter(c)
	return c:IsAbleToHand() and ((not c:IsType(TYPE_FIELD) and c:IsSetCard(0x5d6f)) or c:IsCode(CARD_PESTILENCE))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

function s.actarget(e,te,tp)
	local c=te:GetHandler()
	return c:IsLocation(LOCATION_ONFIELD) and (c:IsCode(CARD_PESTILENCE) or c:GetEquipGroup():FilterCount(Card.IsCode,nil,CARD_PESTILENCE)>0)
end
function s.costchk(e,te_or_c,tp)
	local ct=#{Duel.GetPlayerEffect(tp,id)}
	return Duel.CheckLPCost(tp,ct*500)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,500)
end
function s.tar(e,c)
	return (c:IsFaceup() or c:IsControler(e:GetHandlerPlayer())) and (c:IsCode(CARD_PESTILENCE) or c:GetEquipGroup():FilterCount(Card.IsCode,nil,CARD_PESTILENCE)>0)
end
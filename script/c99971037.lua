--[ Deadmoon ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	
end

function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(function(c) return c:IsAbleToHand() and c:IsCode(99971031) end,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(function(c) return c:IsAbleToHand() and c:IsCode(99971036) end,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.op1f(c)
	return c:IsCode(99971031,99971036) and c:IsAbleToHand()
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsCode,1,nil,99971031)
		and sg:IsExists(Card.IsCode,1,nil,99971036)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.op1f,tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
	if #sg<2 then return end
	local g=aux.SelectUnselectGroup(sg,e,tp,2,2,s.rescon,1,tp,HINTMSG_ATOHAND)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.repfilter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x9d71) or c:IsCode(99971036)) and c:IsLocation(LOCATION_ONFIELD)
		and c:IsControler(tp) and c:IsReason(REASON_EFFECT|REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

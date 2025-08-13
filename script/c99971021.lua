--[ Ven©ªmicTail ]
local s,id=GetID()
function s.initial_effect(c)

	local e99=Effect.CreateEffect(c)
	e99:SetType(EFFECT_TYPE_SINGLE)
	e99:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e99:SetValue(function(e,damp) if e:GetOwnerPlayer()==1-damp then return Duel.GetLP(damp) else return -1 end end)
	c:RegisterEffect(e99)
	
	local e1=MakeEff(c,"Qo","H")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(Cost.SelfDiscard)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"STo")
	e2:SetCategory(CATEGORY_SEARCH_CARD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	
end
function s.tar1f(c)
	return c:IsFaceup() and c:IsSetCard(0x6d71)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and s.tar1f(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tar1f,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tar1f,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsOnField() then 
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3008)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			tc:RegisterEffect(e2)
		end
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_REMOVE)
		e3:SetRange(tc:GetLocation())
		e3:SetTargetRange(0,1)
		e3:SetTarget(function(e) return e:GetHandler()==tc end)
		e3:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e3)
	end
end

function s.tar2f(c)
	return c:IsSetCard(0x6d71) and c:IsAbleToHand() 
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar2f,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tar2f,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

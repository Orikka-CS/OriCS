--[ MST ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.con)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
	
end

function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsPlayerCanDraw(tp,2)
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Duel.IsExistingMatchingCard(s.tar1fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 end
end
function s.tar1fil(c)
	return c:IsCode(CARD_CYCLONE) and c:IsAbleToHand()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local cost_skip=e:GetLabel()~=-100
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsPlayerCanDraw(tp,2)
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Duel.IsExistingMatchingCard(s.tar1fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	if chk==0 then e:SetLabel(0) return b1 or b2 end
	
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	
	if op==1 then
		e:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	elseif op==2 then
		e:SetCategory(CATEGORY_SEARCH_CARD)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	end
end
function s.op1filter(c)
	return c:IsSetCard(0x6d71) or c:IsType(TYPE_QUICKPLAY)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		if not Duel.Draw(tp,2,REASON_EFFECT) then return end
		local g=Duel.GetMatchingGroup(s.op1filter,tp,LOCATION_HAND,0,nil)
		if #g>0 then
			local dg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DISCARD)
			Duel.BreakEffect()
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		else
			local sg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
			Duel.BreakEffect()
			Duel.ConfirmCards(1-tp,sg)
			Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
		end
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tar1fil),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and re:GetHandler():IsCode(CARD_CYCLONE)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end


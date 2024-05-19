--[ Colossus ]
local s,id=GetID()
function s.initial_effect(c)

	YuL.AddColossusSummonProcedure(c)

	local e1=MakeEff(c,"STo")
	e1:SetD(id,0)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	
	local e3=Effect.CreateEffect(c)
	e3:SetD(id,1)
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_F)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(aux.selfreleasecost)
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)
	
	local e8=MakeEff(c,"STo")
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCode(EVENT_RELEASE)
	WriteEff(e8,8,"NTO")
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EVENT_TO_GRAVE)
	e9:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetTurnPlayer()==tp and (r&REASON_ADJUST)~=0 end)
	c:RegisterEffect(e9)
	
end

function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=3-Duel.GetHandLimit(tp)
	if ct<0 then ct=0 end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToDeck() and chkc:IsControler(1-tp) end
	if chk==0 then return ct>0 and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER)) and rp==1-tp
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=re:GetHandler()
	if Duel.GetCurrentChain()~=ev+1 or c:IsStatus(STATUS_BATTLE_DESTROYED) then return end
	if Duel.NegateActivation(ev) then
		if re:IsHasType(EFFECT_TYPE_ACTIVATE) and ec:IsRelateToEffect(re) then
			Duel.SendtoGrave(eg,REASON_EFFECT)
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetLabel(ec:GetOriginalCode())
		e1:SetValue(s.aclimit)
		if Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentPhase()==PHASE_END then
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		end
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetDescription(aux.Stringid(id,2))
		if Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentPhase()==PHASE_END then
			e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
		else
			e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		end
		e2:SetTargetRange(0,1)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.aclimit(e,re,tp)
	return re:GetHandler():GetOriginalCode()==e:GetLabel()
end

function s.con8(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_SUMMON)
end
function s.setfilter(c)
	return c:IsSetCard(0x3d6f) and c:IsSpellTrap() and c:IsSSetable()
end
function s.tar8(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.op8(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
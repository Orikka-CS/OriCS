--[ Stateshifter ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.SelfBanishCost)
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
	
end

function s.tar1f(c,tp)
	return c:IsSetCard(0x5d72) and c:IsMonster() and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar1f,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_DECK)
end
function s.op1f(c)
	return c:IsFacedown() and c:IsSetCard(0x5d72) and c:IsAbleToHand()
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.tar1f,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 and Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)~=0 then
		local g=Duel.GetMatchingGroup(s.op1f,tp,LOCATION_REMOVED,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			Duel.BreakEffect()
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	if tc:IsControler(1-tp) then tc=at end
	e:SetLabelObject(tc)
	return tc:IsControler(tp) and tc:IsSetCard(0x5d72)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return rg:FilterCount(Card.IsAbleToRemove,nil)==3 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,3,0,0)
end
function s.op2val(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFacedown,c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED,nil)*300
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	local g=Duel.GetDecktopGroup(tp,3)
	if g:FilterCount(Card.IsAbleToRemove,nil)==3 and Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		if tc:IsRelateToBattle() and not tc:IsImmuneToEffect(e) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(s.op2val)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
		end
	end
end

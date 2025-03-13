--[ Aranea ]
local s,id=GetID()
function s.initial_effect(c)

	c:EnableReviveLimit()
	aux.AddModuleProcedure(c,aux.FilterBoolFunction(Card.IsModuleRace,RACE_INSECT),nil,1,5,nil)

	local e99=MakeEff(c,"FTf","M")
	e99:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e99:SetCode(EVENT_PHASE+PHASE_END)
	e99:SetCL(1)
	e99:SetOperation(s.op99)
	c:RegisterEffect(e99)
	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DEFENSE_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"I","M")
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCL(1)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	
	local e3=MakeEff(c,"FC","M")
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetCondition(s.negcon)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	
end

function Card.IsAraneaFood(c,def)
	return c:GetAttack()<def or (c:GetDefense()<def and not c:IsType(TYPE_LINK))
end

function s.op99(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(200*ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end

function s.tar2fil(c)
	return c:IsFaceup() and c:IsSetCard(0x3d71) and (c:IsType(TYPE_TUNER) or not c:IsHasEffect(EFFECT_DIRECT_ATTACK))
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tar2fil(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tar2fil,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tar2fil,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_REMOVE_TYPE)
		e2:SetValue(TYPE_TUNER)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
	end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and g and g:IsExists(Card.IsAraneaFood,1,nil,e:GetHandler():GetDefense()) and Duel.IsChainDisablable(ev)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		Duel.NegateEffect(ev)
	end
end

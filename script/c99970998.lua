--[ Aranea ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START|TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
end


function Card.IsAraneaFood(c,def)
	return c:GetAttack()<def or (c:GetDefense()<def and not c:IsType(TYPE_LINK))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_EFFECT|TYPE_MONSTER|TYPE_TUNER,900,1100,5,RACE_INSECT,ATTRIBUTE_FIRE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_EFFECT|TYPE_MONSTER|TYPE_TUNER,900,1100,5,RACE_INSECT,ATTRIBUTE_FIRE) then return end
	c:AddMonsterAttribute(TYPE_EFFECT|TYPE_TRAP|TYPE_TUNER)
	Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
	c:AddMonsterAttributeComplete()

	local e99=MakeEff(c,"FTf","M")
	e99:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e99:SetCode(EVENT_PHASE+PHASE_END)
	e99:SetCL(1)
	e99:SetOperation(s.op99)
	c:RegisterEffect(e99,true)

	local e3=MakeEff(c,"F","M")
	e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.sumtar)
	e3:SetValue(aux.cannotmatfilter(SUMT_F,SUMT_S,SUMT_X,SUMT_L,SUMT_E,SUMT_O,SUMT_M,SUMT_Q,SUMT_B,SUMT_D))
	c:RegisterEffect(e3,true)
	
	Duel.SpecialSummonComplete()
	
end

function s.op99(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		for tc in g:Iter() do
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(-200)
			tc:RegisterEffect(e2)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e3)
		end
	end
end

function s.sumtar(e,c)
	return c:IsAraneaFood(e:GetHandler():GetDefense())
end
function s.fuslimit(e,c,sumtype)
	if not c then return false end
	return not c:IsControler(e:GetHandlerPlayer()) and sumtype==SUMMON_TYPE_FUSION
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end


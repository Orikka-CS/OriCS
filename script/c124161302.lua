--천력투사 시데르파그 아수라
local s,id=GetID()
function s.initial_effect(c)
	--synchro
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FIEND),1,1,Synchro.NonTunerEx(Card.IsSetCard,0xf33),1,99)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1filter(c)
	if not (c:IsType(TYPE_EQUIP) and (c:IsFaceup() or c:GetEquipTarget())) then return false end
	local effs={c:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:GetCode()==EFFECT_UPDATE_ATTACK and eff:IsHasType(EFFECT_TYPE_EQUIP) then
			return true
		end
	end
	return false 
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_SZONE,0,nil)
	return g>0 and 5>g
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_SZONE,0,nil)
	if ct==0 or ct>4 then return end
	local b1=true
	local b2=true
	local b3=true
	local b4=true
	local b 
	for i=1,ct do
		b=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)},{b3,aux.Stringid(id,2)},{b4,aux.Stringid(id,3)})
		if b==1 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(function(e,c) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD)*200 end)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
			c:RegisterEffect(e1)
			b1=false
		end
		if b==2 then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_MUST_ATTACK)
			e2:SetTargetRange(0,LOCATION_MZONE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
			c:RegisterEffect(e2)
			local e2a=e2:Clone()
			e2a:SetCode(EFFECT_MUST_ATTACK_MONSTER)
			e2a:SetValue(function(e,c) return c==e:GetHandler() end)
			c:RegisterEffect(e2a)
			b2=false
		end
		if b==3 then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_ATTACK_ALL)
			e3:SetValue(1)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
			c:RegisterEffect(e3)
			b3=false
		end  
		if b==4 then
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_FIELD)
			e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e4:SetCode(EFFECT_CANNOT_ACTIVATE)
			e4:SetRange(LOCATION_MZONE)
			e4:SetTargetRange(0,1)
			e4:SetValue(function(e,re,tp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsFacedown() and re:GetHandler():IsLocation(LOCATION_SZONE) end)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
			c:RegisterEffect(e4)
			b4=false
		end
	end
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPhase(PHASE_MAIN1) and Duel.IsTurnPlayer(1-tp)
end

function s.tg2filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf33)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_ONFIELD,0,e:GetHandler())
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_ONFIELD,0,e:GetHandler())
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DESTROY)
		if Duel.Destroy(sg,REASON_EFFECT)>0 then
			Duel.SkipPhase(Duel.GetTurnPlayer(),Duel.GetCurrentPhase(),RESET_PHASE+PHASE_END,1)
		end
	end
end
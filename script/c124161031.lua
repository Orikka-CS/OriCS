--피르티리오 타르타로스
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)&LOCATION_ONFIELD)~=0 and rp==1-tp and Duel.IsChainNegatable(ev)
end

function s.tg1filter(c,e)
	return c:IsSetCard(0xf21) and c:IsFaceup() and c:IsCanBeEffectTarget(e)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg1filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return #g>0 and rc:IsAbleToRemove(tp) and Duel.IsPlayerCanRemove(tp) end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,1-tp,LOCATION_ONFIELD)
	end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	local tg=Duel.GetTargetCards(e):GetFirst()
	if not Duel.NegateActivation(ev) or not rc:IsRelateToEffect(re) then return end
	rc:CancelToGrave()
	if Duel.Remove(rc,POS_FACEUP,REASON_EFFECT) then
		local dis=0
		local og=Duel.GetOperatedGroup()
		local target=og:GetFirst()
		for target in aux.Next(og) do
			dis=bit.replace(dis,0x1,target:GetPreviousSequence())
		end
		if rc:IsPreviousLocation(LOCATION_MZONE) then
			dis=dis*0x10000
		else
			dis=dis*0x1000000
			if rc:IsType(TYPE_FIELD) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_ACTIVATE)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e1:SetRange(LOCATION_MZONE)
				e1:SetTargetRange(0,1)
				e1:SetValue(s.op1fact)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tg:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD)
				e2:SetCode(EFFECT_CANNOT_SSET)
				e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e2:SetRange(LOCATION_MZONE)
				e2:SetTargetRange(0,1)
				e2:SetTarget(s.op1fset)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tg:RegisterEffect(e2)
			end
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOperation(function(e) return e:GetLabel() end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabel(dis)
		tg:RegisterEffect(e1)
	end 
end

function s.op1fact(e,re,tp)
	return re and re:IsActiveType(TYPE_FIELD) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end

function s.op1fset(e,c,tp)
	return c:IsType(TYPE_FIELD)
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local a,at=Duel.GetBattleMonster(tp)
	return a and at and a:IsSetCard(0xf21) and a:IsFaceup()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local a,at=Duel.GetAttacker(),Duel.GetAttackTarget()
	if a:IsControler(1-tp) then a,at=at,a end
	if chk==0 then return at and at:IsAbleToRemove() and Duel.IsPlayerCanRemove(tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,at,1,1-tp,LOCATION_MZONE)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a,at=Duel.GetAttacker(),Duel.GetAttackTarget()
	if a:IsControler(1-tp) then a,at=at,a end
	if at and at:IsRelateToBattle() and at:IsControler(1-tp) then
		if Duel.Remove(at,POS_FACEUP,REASON_EFFECT) then
			local dis=0
			local og=Duel.GetOperatedGroup()
			local target=og:GetFirst()
			for target in aux.Next(og) do
				dis=bit.replace(dis,0x1,target:GetPreviousSequence())
			end
			dis=dis*0x10000
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DISABLE_FIELD)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetOperation(function(e) return e:GetLabel() end)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetLabel(dis)
			a:RegisterEffect(e1)
		end
	end
end
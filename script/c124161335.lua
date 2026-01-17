--스노위퍼 메두사이트
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,0xf35))
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SET+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetCondition(s.con2)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1filter(c,e,tp)
	return c:IsControler(1-tp) and e:GetHandler():GetEquipTarget():GetSequence()~=4-c:GetSequence()
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con1filter,nil,e,tp)>0
end

function s.tg1filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end

function s.tg1cfilter(c)
	return c:IsSetCard(0xf35) and c:IsFaceup()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(s.tg1cfilter,tp,LOCATION_ONFIELD,0,c)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return ct>0 and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,c:GetEquipTarget(),1,tp,500)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	local ct=Duel.GetMatchingGroupCount(s.tg1cfilter,tp,LOCATION_ONFIELD,0,c)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_MZONE,nil)
	if ct>0 and #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.TRUE,1,tp,HINTMSG_POSCHANGE)
		Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
		local og=Duel.GetOperatedGroup()
		if og:FilterCount(Card.IsPosition,nil,POS_FACEDOWN_DEFENSE)>0 and ec and ec:IsFaceup() then
			Duel.BreakEffect()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ec:RegisterEffect(e1)
		end
	end
end

--effect 2
function s.con2(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and (ec:GetSequence()==0 or ec:GetSequence()==4)
end

function s.val2(e,te)
	local tp=e:GetHandlerPlayer()
	local ec=e:GetHandler():GetEquipTarget()
	local tc=te:GetHandler()
	local tseq=tc and tc:GetSequence() or -1
	if tc and tc:IsOnField() and tc:GetControler()~=tp then tseq=4-tseq end
	return ec and (ec:GetSequence()==0 or ec:GetSequence()==4) and te:GetOwnerPlayer()~=tp and te:IsActivated() and (not tc:IsOnField() or (tc:IsLocation(LOCATION_MZONE) or tc:IsLocation(LOCATION_SZONE)) and not((ec:GetSequence()==0 and tseq==4) or (ec:GetSequence()==4 and tseq==0)))
end
--스노위퍼 메두사이트
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,0xf35))
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(s.con1)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and (ec:GetSequence()==0 or ec:GetSequence()==4)
end

function s.val1(e,te)
	local tp=e:GetHandlerPlayer()
	local ec=e:GetHandler():GetEquipTarget()
	local tc=te:GetHandler()
	local tseq=tc and tc:GetSequence() or -1
	if tc and tc:IsOnField() and tc:GetControler()~=tp then tseq=4-tseq end
	return ec and (ec:GetSequence()==0 or ec:GetSequence()==4) and te:GetOwnerPlayer()~=tp and te:IsActivated() and (not tc:IsOnField() or (tc:IsLocation(LOCATION_MZONE) or tc:IsLocation(LOCATION_SZONE)) and not((ec:GetSequence()==0 and tseq==4) or (ec:GetSequence()==4 and tseq==0)))
end

--effect 2
function s.con2filter(c,e,tp)
	return  c:IsControler(1-tp) and e:GetHandler():GetEquipTarget():GetSequence()~=4-c:GetSequence()
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,e,tp)>0
end

function s.tg2filter(c,e,tp)
	return s.con2filter(c,e,tp) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsCanTurnSet() and c:IsCanBeEffectTarget(e)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.tg2filter(chkc,e,tp) and eg:IsContains(chkc) end
	local c=e:GetHandler()
	local g=eg:Filter(s.tg2filter,nil,e,tp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_POSCHANGE)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=e:GetHandler():GetEquipTarget()
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg and tg:IsFaceup() and Duel.ChangePosition(tg,POS_FACEDOWN_DEFENSE)>0 then
		Duel.BreakEffect()
		ec:UpdateAttack(500,nil,c)
	end
end
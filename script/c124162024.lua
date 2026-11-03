--말렉스카브 네르갈 티퓨스
local s,id=GetID()
function s.initial_effect(c)
	--synchro
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x5f20),1,1,Synchro.NonTuner(nil),1,99)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.cnt)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetValue(s.val2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--count
function s.cnt(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsContinuousTrap,1,nil) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
	end
end

--effect 1
function s.tg1filter(c,e)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsCanBeEffectTarget(e)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g1=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil,e)
	local g2=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_MZONE,nil,e)
	if chk==0 then return #g1>0 and #g2>0 end
	local sg1=aux.SelectUnselectGroup(g1,e,tp,1,math.min(#g1,#g2),aux.TRUE,1,tp,HINTMSG_POSCHANGE)
	local sg2=aux.SelectUnselectGroup(g2,e,tp,#sg1,#sg1,aux.TRUE,1,tp,HINTMSG_POSCHANGE)
	sg1:Merge(sg2)
	Duel.SetTargetCard(sg1)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg1,#sg1,0,0)
end
function s.op1filter(c,tp)
	return c:IsControler(tp) and c:IsContinuousTrap() and c:IsTrapMonster()
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	local sg=tg:Filter(s.op1filter,nil,tp)
	if #tg==0 or Duel.ChangePosition(tg,POS_FACEDOWN_DEFENSE)==0 then return end
	for tc in sg:Iter() do
		if tc:IsFacedown() and tc:IsLocation(LOCATION_STZONE) and tc:IsControler(tp) then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:GetFlagEffect(id)>0
end
function s.tg2filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
		and (c:IsSetCard(0x5f20) or c:IsContinuousTrap())
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.tg2rfilter(c,e)
	return c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2rfilter,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return eg:FilterCount(s.tg2filter,nil,tp)>0 and #g>0 end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return false end
	Duel.Hint(HINT_CARD,0,id)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DESREPLACE):GetFirst()
	Duel.HintSelection(sg)
	e:SetLabelObject(sg)
	sg:SetStatus(STATUS_DESTROY_CONFIRMED,true)
	return true
end
function s.val2(e,c)
	return s.tg2filter(c,e:GetHandlerPlayer())
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local sg=e:GetLabelObject()
	sg:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(sg,REASON_EFFECT+REASON_REPLACE)
end

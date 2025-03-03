--�˰� ����� �;�
local s,id=GetID()
function s.initial_effect(c)
	--�� ī��� �ߵ� ��, �ʵ忡 ����ؼ� ����,
	local ea=Effect.CreateEffect(c)
	ea:SetType(EFFECT_TYPE_ACTIVATE)
	ea:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(ea)
	local eb=Effect.CreateEffect(c)
	eb:SetType(EFFECT_TYPE_SINGLE)
	eb:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(eb)
	--��� �ʵ忡 "�;� ��ū" 1���� Ư�� ��ȯ�ϴ� �Ϳ� ���� ��� �ʵ忡 �ߵ��� ���� �ִ�.
	local ec=Effect.CreateEffect(c)
	ec:SetType(EFFECT_TYPE_FIELD)
	ec:SetCode(EFFECT_ACTIVATE_COST)
	ec:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET)
	ec:SetTargetRange(1,1)
	ec:SetTarget(s.meiyakutg)
	ec:SetOperation(s.meiyakuop)
	Duel.RegisterEffect(ec,0)
	--�� ī�带 �ı��ϰ�, �� ���� ���� ī�尡 ������ ���, �װ͵鵵 �ı��Ѵ�.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(function(e,tp) return e:GetHandler():GetOwner()==tp and Duel.IsMainPhase() end)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--�� ī�尡 ���� ī���� ȿ���� �ߵ��ϱ� ���� ���ܵǾ��� ��쿡 �ߵ��� �� �ִ�.
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.bncon)
	e2:SetOperation(s.bnop)
	c:RegisterEffect(e2)
end
s.listed_series={0xc16}
s.listed_names={99000295}
function s.meiyakutg(e,te,tp)
	local c=e:GetHandler()
	local tc=te:GetHandler()
	return c==tc and not tc:IsLocation(LOCATION_SZONE) and te:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.meiyakuop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,99000295,0,TYPES_TOKEN,1000,1000,1,RACE_WARRIOR,ATTRIBUTE_LIGHT,POS_FACEUP,1-tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local token=Duel.CreateToken(tp,99000295)
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
		Duel.MoveToField(c,tp,1-tp,LOCATION_FZONE,POS_FACEUP,false)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,67)
	else
		return true
	end
end
function s.cfilter(c,tp)
	return (c:IsNormalSpell() or c:IsHasEffect(99000305,tp)) and c:IsAbleToRemoveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local nc=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
	if chk==0 then 
		if Duel.IsPlayerAffectedByEffect(tp,99000407) then return true else return nc end
	end
	if nc and not (Duel.IsPlayerAffectedByEffect(tp,99000407) and Duel.SelectYesNo(tp,aux.Stringid(99000407,0))) then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.filter(c,g,mc)
	return (g:IsContains(c) or c==mc)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	if chkc then return s.filter(chkc,cg,c) and chkc:IsOnField() end
	if chk==0 then return c:GetFlagEffect(id)==0 and Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,cg,c) end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,cg,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desfilter(c,s,p)
	local seq=c:GetSequence()
	return c:IsControler(p) and math.abs(seq-s)==1
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local seq=tc:GetSequence()
		local dg=Duel.GetMatchingGroup(s.desfilter,tp,tc:GetLocation(),tc:GetLocation(),nil,seq,tc:GetControler())
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and #dg>0 then
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
function s.bncon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return c:IsReason(REASON_COST) and rc:IsType(TYPE_SPELL)
end
function s.bnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--�� �� �߿��� �ڽ� �ʵ��� "�;�" ������ ���ݷ��� 500 �ø���.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xc16))
	e1:SetValue(500)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,2))
end
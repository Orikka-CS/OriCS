--다운폴루스턴 애시데인
local s,id=GetID()
function s.initial_effect(c)
	--synchro
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf36),1,1,Synchro.NonTunerEx(Card.IsType,TYPE_SYNCHRO),1,99)
	--effect 1
	local e1=Effect.CreateEffect(c)
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
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.con2)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
end

--effect 1
function s.tg1filter(c,e)
	return c:IsFaceup() and c:IsSetCard(0xf36) and c:IsCanBeEffectTarget(e)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.tg1filter(chkc,e) end
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_ONFIELD,0,nil,e)
	if chk==0 then return #g>0 and c:GetLevel()>1 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,c,1,0,0)
	if c:GetOriginalLevel()-c:GetLevel()>=3 then
		Duel.SetChainLimit(function(e,ep,tp) return ep==tp end)
	end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:GetLevel()>1 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
	local tg=Duel.GetTargetCards(e):GetFirst()
	if not (tg and tg:IsFaceup()) then return end
	local c=e:GetHandler()
	if not tg:IsImmuneToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(s.op1imfilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tg:RegisterEffect(e1)
	end
end

function s.op1imfilter(e,te)
	return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActivated()
end

--effect 2
function s.con2(e)
	local c=e:GetHandler()
	return c:GetLevel()<c:GetOriginalLevel()
end

function s.val2(e,c)
	local hc=e:GetHandler()
	return (hc:GetOriginalLevel()-hc:GetLevel())*-1
end

--effect 3
function s.val3(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE and not rc:IsLevelAbove(2)
end
--캘라피스 오러젠
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(_,c) return c:IsSetCard(0xf27) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(function(_,c) return c:IsPreviousLocation(LOCATION_REMOVED) end)
	c:RegisterEffect(e3)
	local e3a=e3:Clone()
	e3a:SetCode(EFFECT_QP_ACT_IN_SET_TURN)  
	c:RegisterEffect(e3a)
end

--effect 1
function s.val1filter(c)
	return c:IsSummonLocation(LOCATION_REMOVED) or (c:IsPreviousLocation(LOCATION_REMOVED) and c:IsFacedown())
end

function s.val1(e,c)
	return Duel.GetMatchingGroupCount(s.val1filter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*200
end

--effect2
function s.tg2ffilter(c,cd)
	return c:IsSetCard(0xf27) and c:IsAbleToRemove() and not c:IsCode(cd)
end

function s.tg2filter(c,e,tp)
	return Duel.IsExistingMatchingCard(s.tg2ffilter,tp,LOCATION_DECK,0,1,nil,c:GetCode()) and c:IsCanBeEffectTarget(e) and c:IsFaceup() and c:IsSetCard(0xf27) and not c:IsType(TYPE_FIELD)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tg2filter(chkc,e,tp) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET):GetFirst()
	Duel.SetTargetCard(sg)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetFirstTarget()
	if not sg or not sg:IsRelateToEffect(e) then return end
	local rg=Duel.GetMatchingGroup(s.tg2ffilter,tp,LOCATION_DECK,0,nil,sg:GetCode())
	if #rg==0 then return end
	local srg=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE):GetFirst()
	Duel.Remove(srg,POS_FACEUP,REASON_EFFECT)
	local tg=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,nil,REASON_EFFECT)
	if sg:IsSpellTrap() and sg:IsSSetable() and #tg>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		local stg=aux.SelectUnselectGroup(tg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DISCARD)
		Duel.SendtoGrave(stg,REASON_EFFECT+REASON_DISCARD)
		Duel.SSet(tp,sg)
	end
	if sg:IsMonster() and sg:IsCanBeSpecialSummoned(e,0,tp,false,false) and #tg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		local stg=aux.SelectUnselectGroup(tg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DISCARD)
		Duel.SendtoGrave(stg,REASON_EFFECT+REASON_DISCARD)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	end
end
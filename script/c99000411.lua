--심안의 계시자
local s,id=GetID()
function s.initial_effect(c)
	--module summon
	aux.AddModuleProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER),nil,1,99,s.modulechk)
	c:EnableReviveLimit()
	--자신 또는 상대가 전투 / 효과로 데미지를 받을 경우, 그 수치는 1000 이 된다.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	--Negate the effects of an opponent's monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(aux.NOT(s.quickcon))
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	--This is a Quick Effect if this card has an Illusion monster as material
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E|TIMING_BATTLE_END)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3)
	--If this card battles a monster, neither can be destroyed by that battle
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(s.indestg)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--Keep track of any monster that has battled in a given turn
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={94793422}
function s.modulechk(g)
	local sg=g:Filter(Card.IsLocation,nil,LOCATION_SZONE)
	return sg:IsExists(Card.IsModuleCode,1,nil,94793422)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.GetAttacker():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	local ac=Duel.GetAttackTarget()
	if ac then ac:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1) end
end
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	return g:IsExists(Card.IsRace,1,nil,RACE_FAIRY,c,SUMMON_TYPE_FUSION|SUMMON_TYPE_MODULE,tp)
end
function s.tgfilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,c,tp)
end
function s.cfilter(c,tc,tp)
	if c:IsCode(tc:GetCode(nil,SUMMON_TYPE_FUSION|SUMMON_TYPE_MODULE,tp)) then return false end
	return c:IsMonster() and not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local cc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,tc,tp):GetFirst()
	if not cc then return end
	Duel.ConfirmCards(1-tp,cc)
	local code1,code2=cc:GetOriginalCodeRule()
	--Treat its name as the revealed card's if used for a Fusion Summon
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(code1)
	e1:SetOperation(s.chngcon)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_MODULE_CODE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e2:SetValue(code1)
	tc:RegisterEffect(e2)
	if code2 then
		local e3=e1:Clone()
		e3:SetValue(code2)
		tc:RegisterEffect(e3)
		local e4=e2:Clone()
		e4:SetValue(code2)
		tc:RegisterEffect(e4)
	end
	if tc:HasFlagEffect(id) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.SendtoGrave(cc,REASON_EFFECT)
	end
	if cc:IsLocation(LOCATION_HAND) then Duel.ShuffleHand(tp)
	elseif cc:IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp)
	elseif cc:IsLocation(LOCATION_EXTRA) then Duel.ShuffleExtra(tp) end
end
function s.chngcon(scard,sumtype,tp)
	return (sumtype&MATERIAL_FUSION)~=0
end
function s.indestg(e,c)
	local handler=e:GetHandler()
	return c==handler or c==handler:GetBattleTarget()
end
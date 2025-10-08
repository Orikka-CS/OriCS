--인조천사 후밀리타스
local s,id=GetID()
function s.initial_effect(c)
	--이 카드의 일반 소환을 실행한다.
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_SUMMON)
	e1a:SetType(EFFECT_TYPE_QUICK_O)
	e1a:SetCode(EVENT_FREE_CHAIN)
	e1a:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1a:SetRange(LOCATION_HAND)
	e1a:SetCountLimit(1,id)
	e1a:SetCondition(s.Synthetic_Seraphim_Condition1)
	e1a:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk) e:SetSpellSpeed(3) return true end)
	e1a:SetTarget(s.Synthetic_Seraphim_Target)
	e1a:SetOperation(s.Synthetic_Seraphim_Operation)
	c:RegisterEffect(e1a)
	local e1b=Effect.CreateEffect(c)
	e1b:SetDescription(aux.Stringid(id,0))
	e1b:SetCategory(CATEGORY_SUMMON)
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1b:SetRange(LOCATION_HAND)
	e1b:SetCode(EVENT_CHAINING)
	e1b:SetProperty(EFFECT_FLAG_DELAY)
	e1b:SetCountLimit(1,id)
	e1b:SetCondition(s.Synthetic_Seraphim_Condition2)
	e1b:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk) e:SetSpellSpeed(3) return true end)
	e1b:SetTarget(s.Synthetic_Seraphim_Target)
	e1b:SetOperation(s.Synthetic_Seraphim_Operation)
	c:RegisterEffect(e1b)
	--덱에서 "인조천사" 마법 / 함정 카드 1장을 패에 넣는다.
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk) e:SetSpellSpeed(3) return true end)
	e2a:SetTarget(s.thtg)
	e2a:SetOperation(s.thop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2b)
	local e2c=e2a:Clone()
	e2c:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2c)
	--그 카운터 함정 카드 발동시의 효과를 적용한다.
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,2))
	e3a:SetType(EFFECT_TYPE_ACTIVATE)
	e3a:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3a:SetCode(EVENT_FREE_CHAIN)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetSpellSpeed(3)
	e3a:SetCountLimit(1,{id,2})
	e3a:SetCost(s.cpcost)
	e3a:SetTarget(s.cptg)
	e3a:SetOperation(s.cpop)
	c:RegisterEffect(e3a)
	local e3b=Effect.CreateEffect(c)
	e3b:SetDescription(aux.Stringid(id,2))
	e3b:SetType(EFFECT_TYPE_ACTIVATE)
	e3b:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3b:SetCode(EVENT_SUMMON)
	e3b:SetRange(LOCATION_MZONE)
	e3b:SetSpellSpeed(3)
	e3b:SetCountLimit(1,{id,2})
	e3b:SetCost(s.cpcost)
	e3b:SetTarget(s.cptg)
	e3b:SetOperation(s.cpop)
	c:RegisterEffect(e3b)
	local e3c=Effect.CreateEffect(c)
	e3c:SetDescription(aux.Stringid(id,2))
	e3c:SetType(EFFECT_TYPE_ACTIVATE)
	e3c:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3c:SetCode(EVENT_FLIP_SUMMON)
	e3c:SetRange(LOCATION_MZONE)
	e3c:SetSpellSpeed(3)
	e3c:SetCountLimit(1,{id,2})
	e3c:SetCost(s.cpcost)
	e3c:SetTarget(s.cptg)
	e3c:SetOperation(s.cpop)
	c:RegisterEffect(e3c)
	local e3d=Effect.CreateEffect(c)
	e3d:SetDescription(aux.Stringid(id,2))
	e3d:SetType(EFFECT_TYPE_ACTIVATE)
	e3d:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3d:SetCode(EVENT_SPSUMMON)
	e3d:SetRange(LOCATION_MZONE)
	e3d:SetSpellSpeed(3)
	e3d:SetCountLimit(1,{id,2})
	e3d:SetCost(s.cpcost)
	e3d:SetTarget(s.cptg)
	e3d:SetOperation(s.cpop)
	c:RegisterEffect(e3d)
	--이 효과의 발동은 카운터 함정 카드의 발동으로도 취급한다.
	local e4a=Effect.CreateEffect(c)
	e4a:SetType(EFFECT_TYPE_FIELD)
	e4a:SetCode(EFFECT_ACTIVATE_COST)
	e4a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET)
	e4a:SetTargetRange(1,1)
	e4a:SetTarget(function(e,te,tp) return te==e:GetLabelObject() end)
	e4a:SetOperation(
	function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TRAP+TYPE_COUNTER)
		e1:SetReset(RESET_CHAIN)
		c:RegisterEffect(e1,true)
	end)
	e4a:SetLabelObject(e3a)
	Duel.RegisterEffect(e4a,0)
	local e4b=e4a:Clone()
	e4b:SetLabelObject(e3b)
	Duel.RegisterEffect(e4b,0)
	local e4c=e4a:Clone()
	e4c:SetLabelObject(e3c)
	Duel.RegisterEffect(e4c,0)
	local e4d=e4a:Clone()
	e4d:SetLabelObject(e3d)
	Duel.RegisterEffect(e4d,0)
end
s.listed_series={0xc12}
function s.Synthetic_Seraphim_Filter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsRace(RACE_FAIRY)
end
function s.Synthetic_Seraphim_Condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.Synthetic_Seraphim_Filter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil)
end
function s.Synthetic_Seraphim_Condition2(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_COUNTER)
end
function s.Synthetic_Seraphim_Target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSummonable(true,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,tp,0)
end
function s.Synthetic_Seraphim_Operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Summon(tp,c,true,nil)~=0 then
		--이 효과로 일반 소환한 이 카드를 싱크로 소재로 할 경우, 이 카드를 튜너 이외의 몬스터로 취급할 수 있다.
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_NONTUNER)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e1)
	end
end
function s.thfilter(c)
	return (c:IsCode(16946849) or c:IsCode(16946850) or c:IsSetCard(0xc12)) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.cpfilter(c)
	aux.CheckDisSumAble=true
	if not (c:CheckActivateEffect(false,true,false)~=nil) then return false end
	aux.CheckDisSumAble=false
	return c:IsCounterTrap()
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return Duel.CheckLPCost(tp,1400) and Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	e:SetLabel(0)
	Duel.PayLPCost(tp,1400)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	aux.CheckDisSumAble=true
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	aux.CheckDisSumAble=false
	Duel.ClearOperationInfo(0)
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	if not te:GetHandler():IsRelateToEffect(e) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
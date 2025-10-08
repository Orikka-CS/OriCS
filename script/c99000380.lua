--인조천사 카리타스
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,s.mfilter,4,2)
	c:EnableReviveLimit()
	--자신 필드에 "인조천사"가 존재하고, 상대 필드에 천사족 몬스터가 엑스트라 덱에서 특수 소환되었을 경우, 이 카드를 엑시즈 소환할 수 있다.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--필드의 앞면 표시 몬스터 및 묘지의 몬스터는 천사족이 된다.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(RACE_FAIRY)
	e2:SetTarget(s.tg)
	c:RegisterEffect(e2)
	--이 효과는, 그 카운터 함정 카드 발동시의 효과와 같아진다.
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,1))
	e3a:SetType(EFFECT_TYPE_ACTIVATE)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetCode(EVENT_FREE_CHAIN)
	e3a:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_MSET|TIMINGS_CHECK_MONSTER_E)
	e3a:SetSpellSpeed(3)
	e3a:SetCondition(s.effcon)
	e3a:SetCost(s.effcost)
	e3a:SetTarget(s.efftg)
	e3a:SetOperation(s.effop)
	c:RegisterEffect(e3a)
	local e3b=Effect.CreateEffect(c)
	e3b:SetDescription(aux.Stringid(id,1))
	e3b:SetType(EFFECT_TYPE_ACTIVATE)
	e3b:SetRange(LOCATION_MZONE)
	e3b:SetCode(EVENT_SUMMON)
	e3b:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_MSET|TIMINGS_CHECK_MONSTER_E)
	e3b:SetSpellSpeed(3)
	e3b:SetCondition(s.effcon)
	e3b:SetCost(s.effcost)
	e3b:SetTarget(s.efftg)
	e3b:SetOperation(s.effop)
	c:RegisterEffect(e3b)
	local e3c=Effect.CreateEffect(c)
	e3c:SetDescription(aux.Stringid(id,1))
	e3c:SetType(EFFECT_TYPE_ACTIVATE)
	e3c:SetRange(LOCATION_MZONE)
	e3c:SetCode(EVENT_FLIP_SUMMON)
	e3c:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_MSET|TIMINGS_CHECK_MONSTER_E)
	e3c:SetSpellSpeed(3)
	e3c:SetCondition(s.effcon)
	e3c:SetCost(s.effcost)
	e3c:SetTarget(s.efftg)
	e3c:SetOperation(s.effop)
	c:RegisterEffect(e3c)
	local e3d=Effect.CreateEffect(c)
	e3d:SetDescription(aux.Stringid(id,1))
	e3d:SetType(EFFECT_TYPE_ACTIVATE)
	e3d:SetRange(LOCATION_MZONE)
	e3d:SetCode(EVENT_SPSUMMON)
	e3d:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_MSET|TIMINGS_CHECK_MONSTER_E)
	e3d:SetSpellSpeed(3)
	e3d:SetCondition(s.effcon)
	e3d:SetCost(s.effcost)
	e3d:SetTarget(s.efftg)
	e3d:SetOperation(s.effop)
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
s.listed_names={16946849}
s.listed_series={0xc12}
function s.mfilter(c)
	return c:IsCode(16946849) or c:IsCode(16946850) or c:IsSetCard(0xc12)
end
function s.spfilter(c,tp)
	return c:IsControler(1-tp) and c:IsRace(RACE_FAIRY) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil,tp) and e:GetHandler():IsXyzSummonable()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,16946849),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsXyzSummonable() and Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,0)) then
		Duel.XyzSummon(tp,c,nil)
	end
end
function s.tg(e,c)
	if c:GetFlagEffect(1)==0 then
		c:RegisterFlagEffect(1,0,0,0)
		local eff
		if c:IsLocation(LOCATION_MZONE) then
			eff={Duel.GetPlayerEffect(c:GetControler(),EFFECT_NECRO_VALLEY)}
		else
			eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
		end
		c:ResetFlagEffect(1)
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then return false end
		end
	end
	return true
end
function s.Synthetic_Seraphim_Filter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsRace(RACE_FAIRY)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.Synthetic_Seraphim_Filter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil) then
		return true
	else
		return Duel.GetFlagEffect(tp,id)<1
	end
end
function s.copyfilter(c)
	aux.CheckDisSumAble=true
	if not (c:CheckActivateEffect(false,true,true)~=nil) then return false end
	aux.CheckDisSumAble=false
	return c:IsCounterTrap() and c:IsAbleToGraveAsCost()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		local res=c:CheckRemoveOverlayCard(tp,1,REASON_COST) or Duel.CheckLPCost(tp,1400)
		local res2=Duel.IsExistingMatchingCard(s.copyfilter,tp,LOCATION_DECK,0,1,nil)
		return res and res2
	end
	e:SetLabel(0)
	local b1=c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	local b2=Duel.CheckLPCost(tp,1400)
	if b1~=false and (not b2~=false or Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==0) then
		c:RemoveOverlayCard(tp,1,1,REASON_COST)
	else
		Duel.PayLPCost(tp,1400)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.copyfilter,tp,LOCATION_DECK,0,1,1,nil)
	aux.CheckDisSumAble=true
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	aux.CheckDisSumAble=false
	Duel.ClearOperationInfo(0)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
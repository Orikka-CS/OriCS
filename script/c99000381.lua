--인조천사 파티엔티아
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,s.sfilter,2,2,s.sfilter2,1,99)
	c:EnableReviveLimit()
	--Multiple tuners
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_MULTIPLE_TUNERS)
	c:RegisterEffect(e0)
	--자신 필드에 "인조천사"가 존재하고, 상대 필드에 천사족 몬스터가 엑스트라 덱에서 특수 소환되었을 경우, 이 카드를 싱크로 소환할 수 있다.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--자신의 "인조천사" 몬스터는 앞면 수비 표시 그대로 공격할 수 있다(데미지 계산에서는 수비력을 공격력으로 취급한다).
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_DEFENSE_ATTACK)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetTargetRange(LOCATION_MZONE,0)
	e2a:SetTarget(function(e,c) return c:IsCode(16946849) or c:IsCode(16946850) or c:IsSetCard(0xc12) end)
	e2a:SetValue(1)
	c:RegisterEffect(e2a)
	--자신의 천사족 몬스터가 수비 표시 몬스터를 공격했을 경우, 그 수비력을 공격력이 넘은 만큼만 상대에게 전투 데미지를 준다.
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD)
	e2b:SetCode(EFFECT_PIERCE)
	e2b:SetRange(LOCATION_MZONE)
	e2b:SetTargetRange(LOCATION_MZONE,0)
	e2b:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FAIRY))
	c:RegisterEffect(e2b)
	--상대 필드의 천사족 몬스터는 수비 표시가 되고,
	local e2c=Effect.CreateEffect(c)
	e2c:SetType(EFFECT_TYPE_FIELD)
	e2c:SetCode(EFFECT_SET_POSITION)
	e2c:SetRange(LOCATION_MZONE)
	e2c:SetTarget(function(e,c) return c:IsRace(RACE_FAIRY) end)
	e2c:SetTargetRange(0,LOCATION_MZONE)
	e2c:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e2c)
	--상대는 천사족 몬스터의 효과를 발동할 수 없다.
	local e2d=Effect.CreateEffect(c)
	e2d:SetType(EFFECT_TYPE_FIELD)
	e2d:SetRange(LOCATION_MZONE)
	e2d:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2d:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2d:SetTargetRange(0,1)
	e2d:SetValue(function(e,re,tp) return re:GetHandler():IsRace(RACE_FAIRY) and re:IsMonsterEffect() end)
	c:RegisterEffect(e2d)
	--그것을 무효로 하고, 그 몬스터를 파괴한다.
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,1))
	e3a:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e3a:SetType(EFFECT_TYPE_ACTIVATE)
	e3a:SetCode(EVENT_SUMMON)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetSpellSpeed(3)
	e3a:SetCondition(s.discon)
	e3a:SetCost(s.discost)
	e3a:SetTarget(s.distg)
	e3a:SetOperation(s.disop)
	c:RegisterEffect(e3a)
	local e3b=Effect.CreateEffect(c)
	e3b:SetDescription(aux.Stringid(id,1))
	e3b:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e3b:SetType(EFFECT_TYPE_ACTIVATE)
	e3b:SetCode(EVENT_FLIP_SUMMON)
	e3b:SetRange(LOCATION_MZONE)
	e3b:SetSpellSpeed(3)
	e3b:SetCondition(s.discon)
	e3b:SetCost(s.discost)
	e3b:SetTarget(s.distg)
	e3b:SetOperation(s.disop)
	c:RegisterEffect(e3b)
	local e3c=Effect.CreateEffect(c)
	e3c:SetDescription(aux.Stringid(id,1))
	e3c:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e3c:SetType(EFFECT_TYPE_ACTIVATE)
	e3c:SetCode(EVENT_SPSUMMON)
	e3c:SetRange(LOCATION_MZONE)
	e3c:SetSpellSpeed(3)
	e3c:SetCondition(s.discon)
	e3c:SetCost(s.discost)
	e3c:SetTarget(s.distg)
	e3c:SetOperation(s.disop)
	c:RegisterEffect(e3c)
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
end
s.listed_names={16946849}
s.listed_series={0xc12}
function s.sfilter(c)
	return c:IsCode(16946849) or c:IsCode(16946850) or c:IsSetCard(0xc12)
end
function s.sfilter2(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.spfilter(c,tp)
	return c:IsControler(1-tp) and c:IsRace(RACE_FAIRY) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil,tp) and e:GetHandler():IsSynchroSummonable()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,16946849),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsSynchroSummonable() and Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,0)) then
		Duel.SynchroSummon(tp,c,nil)
	end
end
function s.Synthetic_Seraphim_Filter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsRace(RACE_FAIRY)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.Synthetic_Seraphim_Filter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil) then
		return Duel.GetCurrentChain()==0
	else
		return Duel.GetCurrentChain()==0 and Duel.GetFlagEffect(tp,id)<1
	end
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return Duel.CheckLPCost(tp,1400)
	end
	e:SetLabel(0)
	Duel.PayLPCost(tp,1400)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.NegateSummon(eg)
	for tc in eg:Iter() do
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			--이 턴에, 이 효과로 파괴한 몬스터 및 그 몬스터와 원래의 카드명이 같은 몬스터의 효과는 무효화된다.
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_DISABLE)
			e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e3:SetTarget(s.ngtg)
			e3:SetLabel(tc:GetOriginalCodeRule())
			e3:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e3,tp)
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e4:SetCode(EVENT_CHAIN_SOLVING)
			e4:SetCondition(s.ngcon)
			e4:SetOperation(s.ngop)
			e4:SetLabel(tc:GetOriginalCodeRule())
			e4:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e4,tp)
		end
	end
end
function s.ngtg(e,c)
	local code=e:GetLabel()
	local code1,code2=c:GetOriginalCodeRule()
	return code1==code or code2==code
end
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	local code1,code2=re:GetHandler():GetOriginalCodeRule()
	return re:IsMonsterEffect() and (code1==code or code2==code)
end
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateEffect(ev)
end
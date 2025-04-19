--퍼펙트 치르노
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterSummonCode(199900000),1,1,aux.FilterSummonCode(199900002),1,1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.tar2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	e4:SetValue(s.val4)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetValue(s.val5)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_DIRECT_ATTACK)
	e6:SetCondition(s.con6)
	c:RegisterEffect(e6)
end
s.material={199900000,199900002}
s.listed_names={199900000,199900002}
local gfilter=Group.Filter
function Group.Filter(group,filter,exceptions,param1,...)
	if type(filter)=="function" and filter==Card.IsCanBeSynchroMaterial
		and type(param1)=="Card" and param1:GetOriginalCodeRule()==199900001 then
		local tp=param1:GetControler()
		local addmat=Duel.GetMatchingGroup(function(c)
			return c:IsFaceup() and c:IsCode(199900002)
		end,tp,LOCATION_FZONE,0,param1)
		local newgroup=group:Clone()
		newgroup:Merge(addmat)
		return gfilter(newgroup,filter,exceptions,param1,...)
	end
	return gfilter(group,filter,exceptions,param1,...)
end
local cicbsm=Card.IsCanBeSynchroMaterial
function Card.IsCanBeSynchroMaterial(c,sc,...)
	if c:IsCode(199900002) and c:IsLocation(LOCATION_FZONE) and sc:GetOriginalCodeRule()==199900001 then
		return true
	end
	return cicbsm(c,sc,...)
end
local cgsl=Card.GetSynchroLevel
function Card.GetSynchroLevel(c,sc,...)
	if c:IsCode(199900002) and c:IsLocation(LOCATION_FZONE) and sc:GetOriginalCodeRule()==199900001 then
		return 9
	end
	return cgsl(c,sc,...)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.tfil1(c)
	return c:IsOriginalCode(199900023) and not c:IsForbidden()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil1,tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.tfil1,tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	local tc=g:GetFirst()
	if not tc then
		return
	end
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if fc then
		Duel.SendtoGrave(fc,REASON_RULE)
		Duel.BreakEffect()
	end
	Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
end
function s.tar2(e,c)
	return c:IsDefensePos()
end
function s.val3(e,re,rp)
	local tp=e:GetHandlerPlayer()
	local rc=re:GetHandler()
	return rc:IsControler(1-tp) and rc:IsDefensePos() and rc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER)
end
function s.val4(e,re,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.vfil5(c)
	return c:IsDefensePos() or (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFacedown())
end
function s.val5(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetMatchingGroupCount(s.vfil5,tp,0,LOCATION_ONFIELD,nil)*900
end
function s.con6(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IsExistingMatchingCard(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil)
end

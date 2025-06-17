--자전의 디바인 드래곤 에를쾨니히
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),1,1,Synchro.NonTunerEx(s.pfil1),1,99)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetValue(s.val4)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.con5)
	e5:SetTarget(s.tar5)
	e5:SetOperation(s.op5)
	c:RegisterEffect(e5)
end
function s.pfil1(c,val,scard,sumtype,tp)
	return c:IsRace(RACE_FIEND+RACE_DRAGON,scard,sumtype,tp) and c:IsAttribute(ATTRIBUTE_DARK,scard,sumtype,tp)
		and c:IsType(TYPE_SYNCHRO,scard,sumtype,tp)
end
function s.tfil1(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON+RACE_FIEND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.tfil1,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),2)
	if ft<=0 then
		return
	end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		ft=1
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tfil1),tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
function s.val2(e,te)
	local tc=te:GetHandler()
	return te:GetOwner()~=e:GetOwner() and tc:IsAttribute(ATTRIBUTE_DARK) and te:IsActiveType(TYPE_MONSTER)
end
function s.val3(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
function s.val4(e,re)
	local rc=re:GetHandler()
	return rc:IsAttribute(ATTRIBUTE_DARK) and re:IsActiveType(TYPE_MONSTER)
end
function s.nfil5(c,tp)
	return c:IsPreviousControler(1-tp)
end
function s.con5(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.nfil5,1,nil,tp)
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)
			+Duel.GetLocationCount(tp,LOCATION_SZONE,PLAYER_NONE,0)
			+Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)
			+Duel.GetLocationCount(1-tp,LOCATION_SZONE,PLAYER_NONE,0)>1
	end
	local dis=Duel.SelectDisableField(tp,2,LOCATION_ONFIELD,LOCATION_ONFIELD,0)
	Duel.Hint(HINT_ZONE,tp,dis)
	Duel.SetTargetParam(dis)
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(s.ocon51)
	e1:SetOperation(function(e)
		return e:GetLabel()
	end)
	e1:SetLabel(Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM))
	Duel.RegisterEffect(e1,tp)
end
function s.onfil51(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND+RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
function s.ocon51(e)
	local res=Duel.IsExistingMatchingCard(s.onfil21,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	if not res then
		e:Reset()
		return false
	end
	return true
end
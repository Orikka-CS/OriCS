--멸망의 용신 리제
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,15480032,
		aux.FilterBoolFunctionEx(Card.IsType,TYPE_RITUAL+TYPE_XYZ+TYPE_SYNCHRO+TYPE_FUSION+TYPE_PENDULUM+TYPE_LINK))
	Pendulum.AddProcedure(c,false)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_DRAGON))
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.tar4)
	e4:SetOperation(s.op4)
	c:RegisterEffect(e4)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CANNOT_ACTIVATE)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetRange(LOCATION_PZONE)
	e6:SetTargetRange(0,1)
	e6:SetValue(s.val6)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_PZONE)
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetCountLimit(1)
	e7:SetTarget(s.tar7)
	e7:SetOperation(s.op7)
	c:RegisterEffect(e7)
end
function s.tfil2(c,e,tp)
	if not (c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)) then
		return false
	end
	local g=Duel.GetMatchingGroup(aux.NOT(aux.FaceupFilter(Card.IsCode,id)),tp,LOCATION_MZONE,0,nil)
	if c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,g,c)>0
	else
		return Duel.GetMZoneCount(tp,g)>0
	end
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.NOT(aux.FaceupFilter(Card.IsCode,id)),tp,LOCATION_MZONE,0,nil)
	if chk==0 then
		return #g>0 and Duel.IsExistingMatchingCard(s.tfil2,tp,
			LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end
function s.ofil21(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
function s.ofil22(c)
	return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end
function s.ofun2(ft1,ft2,ft3,ft4,ft)
	return
		function(sg,e,tp,mg)
			local exnpct=sg:FilterCount(s.ofil21,nil)
			local expct=sg:FilterCount(s.ofil22,nil)
			local mct=sg:FilterCount(aux.NOT(Card.IsLocation),nil,LOCATION_EXTRA)
			local exct=sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
			local groupcount=#sg
			local classcount=sg:GetClassCount(Card.GetCode)
			local res=ft3>=exnpct and ft4>=expct and ft1>=mct and ft>=groupcount and classcount==groupcount
			return res,not res
		end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dg=Duel.GetMatchingGroup(aux.NOT(aux.FaceupFilter(Card.IsCode,id)),tp,LOCATION_MZONE,0,nil)
	if #dg==0 or Duel.Destroy(dg,REASON_EFFECT)==0 then
		return
	end
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCountFromEx(tp)
	local ft3=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	local ft4=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
	local ft=math.min(Duel.GetUsableMZoneCount(tp),4)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		if ft1>0 then ft1=1 end
		if ft2>0 then ft2=1 end
		if ft3>0 then ft3=1 end
		if ft4>0 then ft4=1 end
		ft=1
	end
	local ect=aux.CheckSummonGate(tp)
	if ect then
		ft1 = math.min(ect,ft1)
		ft2 = math.min(ect,ft2)
		ft3 = math.min(ect,ft3)
		ft4 = math.min(ect,ft4)
	end
	local loc=0
	if ft1>0 then
		loc=loc+LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE
	end
	if ft2>0 or ft3>0 or ft4>0 then
		loc=loc+LOCATION_EXTRA
	end
	if loc==0 then
		return
	end
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tfil2),tp,loc,0,nil,e,tp)
	if #sg==0 then
		return
	end
	local rg=aux.SelectUnselectGroup(sg,e,tp,1,ft,s.ofun2(ft1,ft2,ft3,ft4,ft),1,tp,HINTMSG_SPSUMMON)
	if Duel.SpecialSummon(rg,0,tp,tp,true,false,POS_FACEUP)>0 and c:IsRelateToEffect(e) and c:IsFaceup()
		and (c:GetAttack()~=30000 or c:GetDefense()~=30000) then
		Duel.BreakEffect()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(30000)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		c:RegisterEffect(e2)
	end
end
function s.val3(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.tfil4(c)
	return c:IsRace(RACE_DRAGON) and c:IsFaceup()
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil4,tp,LOCATION_MZONE,0,1,nil)	
	end
	local dam=Duel.GetMatchingGroupCount(s.tfil4,tp,LOCATION_MZONE,0,nil)*1000
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local dam=Duel.GetMatchingGroupCount(s.tfil4,tp,LOCATION_MZONE,0,nil)*1000
	Duel.Damage(p,dam,REASON_EFFECT)
end

function s.con5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		 return Duel.CheckPendulumZones(tp)
	end
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.CheckPendulumZones(tp) then
		return false
	end
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.val6(e,re,rp)
	local rc=re:GetHandler()
	return rc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER)
		and rc:IsType(TYPE_RITUAL+TYPE_XYZ+TYPE_SYNCHRO+TYPE_FUSION+TYPE_PENDULUM+TYPE_LINK)
end
function s.tfil7(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar7(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.tfil7,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.op7(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.tfil7,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
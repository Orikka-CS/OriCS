--해황원수 포세이도라 바레오스
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,9,3,s.pfil1,aux.Stringid(id,0),3,s.pop1)
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
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cost2)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.con3)
	e3:SetCost(s.cost3)
	e3:SetTarget(s.tar3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ATLANTEAN}
s.listed_names={id}
function s.pfil1(c,tp,lc)
	return c:IsFaceup()
		and (c:IsSetCard(SET_ATLANTEAN,lc,SUMMON_TYPE_XYZ,tp) or c:IsAttribute(ATTRIBUTE_WATER,lc,SUMMON_TYPE_XYZ,tp))
		and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp) 
end
function s.pop1(e,tp,chk)
	if chk==0 then
		return not Duel.HasFlagEffect(tp,id)
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
	return true
end
function s.tfil1(c,e,tp)
	if not (c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_SEASERPENT)) then
		return false
	end
	if c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil1,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.ofil11(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
function s.ofil12(c)
	return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end
function s.ofun1(ft1,ft2,ft3,ft4,ft)
	return
		function(sg,e,tp,mg)
			local exnpct=sg:FilterCount(s.ofil11,nil)
			local expct=sg:FilterCount(s.ofil12,nil)
			local mct=sg:FilterCount(aux.NOT(Card.IsLocation),nil,LOCATION_EXTRA)
			local exct=sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
			local groupcount=#sg
			local classcount=sg:GetClassCount(Card.GetCode)
			local rg=mg:Clone():Sub(sg)
			local sres=(ft3-exnpct<=0 or not mg:IsExists(s.ofil11,1,nil))
				and (ft4-expct<=0 or not mg:IsExists(s.ofil12,1,nil))
				and (ft1-mct<=0 or not mg:IsExists(aux.NOT(Card.IsLocation),1,nil,LOCATION_EXTRA))
			local res=ft3>=exnpct and ft4>=expct and ft1>=mct and ft>=groupcount and classcount==groupcount
			return res,not res
		end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCountFromEx(tp)
	local ft3=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	local ft4=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
	local ft=Duel.GetUsableMZoneCount(tp)
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
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tfil1),tp,loc,0,nil,e,tp)
	if #sg==0 then
		return
	end
	local rg=aux.SelectUnselectGroup(sg,e,tp,1,ft,s.ofun1(ft1,ft2,ft3,ft4,ft),1,tp,HINTMSG_SPSUMMON)
end
function s.cfil2(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGraveAsCost()
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:CheckRemoveOverlayCard(tp,2,REASON_COST)
			and Duel.IsExistingMatchingCard(s.cfil2,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil)
	end
	c:RemoveOverlayCard(tp,2,2,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfil2,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tfil2(c)
	return c:IsFaceup() and c:GetAttack()>0
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil2,tp,0,LOCATION_MZONE,1,nil)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsXyzSummoned()
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.AND(Card.IsDiscardable,Card.IsAbleToGraveAsCost),tp,LOCATION_HAND,0,1,nil)
	end
	Duel.DiscardHand(tp,aux.AND(Card.IsDiscardable,Card.IsAbleToGraveAsCost),1,1,REASON_COST|REASON_DISCARD)
end
function s.tfil3(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_FISH|RACE_SEASERPENT|RACE_AQUA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>=3
			and Duel.IsExistingMatchingCard(s.tfil3,tp,LOCATION_HAND|LOCATION_GRAVE,0,3,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tfil3),tp,LOCATION_HAND|LOCATION_GRAVE,0,3,3,nil,e,tp)
	if #g==3 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
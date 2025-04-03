--나츄르 허밍버드
local s,id=GetID()
function s.initial_effect(c)
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_EARTH),2,2)
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.val0)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_MATERIAL)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(1,0)
	e1:SetOperation(s.op1)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con2)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	e2:SetLabelObject(e0)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetCondition(s.con3)
	e3:SetCost(aux.CostWithReplace(s.cost3,CARD_NATURIA_CAMELLIA))
	e3:SetTarget(s.tar3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end
s.listed_series={0x2a}
function s.val0(e,c)
	local g=c:GetMaterial()
	e:SetLabel(0)
	if g:IsExists(Card.IsSetCard,1,nil,0x2a) then
		e:SetLabel(1)
	end
end
function s.op1(c,e,tp,sg,mg,lc,og,chk)
	if not s.pg1 then
		return true
	end
	return #(sg&s.pg1)<=1
end
function s.vfil1(c)
	return c:IsSetCard(0x2a) and c:IsType(TYPE_MONSTER)
end
function s.val1(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or sc~=c then
			return Group.CreateGroup()
		else
			s.pg1=Duel.GetMatchingGroup(s.vfil1,tp,LOCATION_HAND,0,nil)
			s.pg1:KeepAlive()
			return s.pg1
		end
	elseif chk==2 then
		if s.pg1 then
			s.pg1:DeleteGroup()
		end
		s.pg1=nil
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local te=e:GetLabelObject()
	return c:IsSummonType(SUMMON_TYPE_LINK) and te:GetLabel()==1
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
function s.tfil2(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x2a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.tfil2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tfil2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	local rc=re:GetHandler()
	return (loc&LOCATION_ONFIELD)~=0 and rc~=c and Duel.IsChainNegatable(ev)
end
function s.cfil3(c)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsReleasable() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
			and Duel.CheckReleaseGroupCost(tp,s.cfil3,1,false,nil,c)
	end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfil3,1,1,false,nil,c)
	Duel.Release(g:AddCard(c),REASON_COST)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

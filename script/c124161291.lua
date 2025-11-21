--RUT－체어라키 포스
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1a:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1a:SetValue(function(e) e:SetLabel(1) end)
	e1a:SetCondition(function(e) return Duel.CheckRemoveOverlayCard(e:GetHandlerPlayer(),1,0,1,REASON_COST) end)
	c:RegisterEffect(e1a)
	e1:SetLabelObject(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	local label_obj=e:GetLabelObject()
	if chk==0 then label_obj:SetLabel(0) return true end
	if label_obj:GetLabel()>0 then
		label_obj:SetLabel(0)
		Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
	end
end

function s.tg1xfilter(c)
	return c:IsSetCard(0xf32) and c:IsAbleToRemove()
end

function s.tg1filter(c,e,tp)
	local mustg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	local g=Duel.GetMatchingGroupCount(s.tg1xfilter,tp,LOCATION_GRAVE,0,nil)
	if g==0 then return false end
	return c:IsType(TYPE_XYZ) and #mustg<=1 and c:IsFaceup() and Duel.IsExistingMatchingCard(s.tg1ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank(),g,mustg)
end

function s.tg1ffilter(c,e,tp,mc,rk,ct,mustg)
	return c:IsSetCard(0xf32) and (c:IsRankAbove(rk+1) and c:IsRankBelow(rk+ct)) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c,tp) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and (#mustg<=0 or mustg:IsContains(mc)) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tg1filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tg1filter,tp,LOCATION_MZONE,0,1,c,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tg1filter,tp,LOCATION_MZONE,0,1,1,c,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local g=Duel.GetMatchingGroup(s.tg1xfilter,tp,LOCATION_GRAVE,0,nil)
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and not tc:IsImmuneToEffect(e)) then return end
	local mustg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.tg1ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank(),#g,mustg):GetFirst()
	if sc then
		local ct=sc:GetRank()-tc:GetRank()
		local sg=aux.SelectUnselectGroup(g,e,tp,ct,ct,aux.TRUE,1,tp,HINTMSG_REMOVE)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		sc:SetMaterial(tc)
		Duel.Overlay(sc,tc)
		if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)==0 then return end
		sc:CompleteProcedure()
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0xf32)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,tp)>0 and not eg:IsContains(e:GetHandler())
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsSSetable() then
		Duel.SSet(tp,c)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1)
	end
end
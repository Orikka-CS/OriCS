--소울 슬레이어-아쥬레
local s,id=GetID()
function s.initial_effect(c)
	--summon process
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	c:RegisterEffect(e2)
	--adjust
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.adjustcon)
	e3:SetOperation(s.adjustop)
	c:RegisterEffect(e3)
	--Fusion, Synchro, and Xyz material limitations
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_FUSION_MAT_RESTRICTION)
	e4:SetValue(s.filter)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SYNCHRO_MAT_RESTRICTION)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_XYZ_MAT_RESTRICTION)
	c:RegisterEffect(e6)
	--Link material limitations (external utilities needed)
	local e7=e4:Clone()
	e7:SetCode(73941492+TYPE_LINK)
	c:RegisterEffect(e7)
	--Custom Summon Type material limitations (external utilities needed)
	local e8=e4:Clone()
	e8:SetCode(73941492+TYPE_SPSUMMON)
	e8:SetValue(s.matfilter)
	c:RegisterEffect(e8)
end
s.listed_series={0x903}
--summon process
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
--adjust
function s.desfilter(c,e)
	return not c:IsImmuneToEffect(e) and c:IsDestructable(e)
		and not c:IsSetCard(0x903) and (c:IsLevelAbove(10) or c:IsRankAbove(10) or c:IsLinkAbove(7))
end
function s.adjustcon(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if #g>0 then
		e:GetHandler():CreateEffectRelation(e)
		return true
	end
	return false
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if #g>0 then
		Duel.Hint(HINT_CARD,0,id)
		Duel.SendtoGrave(g,REASON_EFFECT|REASON_DESTROY,PLAYER_NONE,tp)
		Duel.Readjust()
	end
end
--material limitations
function s.filter(e,c)
	return c:IsSetCard(0x903)
end
function s.matfilter(e,c,sumtype,tp)
	return c:IsSetCard(0x903)
end

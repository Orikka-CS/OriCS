--소울 슬레이어-느와르
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.xyzfilter,nil,2,nil,nil,nil,nil,false,s.xyzcheck)
	--adjust
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.adjustcon)
	e3:SetOperation(s.adjustop)
	c:RegisterEffect(e3)
end
s.listed_series={0x903}
--xyz summon
function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsSetCard(0x903,xyz,sumtype,tp) and not c:IsXyzLevel(xyz,0)
end
function s.xyzcheck(g,tp,xyz)
	local mg=g:Filter(function(c) return not c:IsHasEffect(511001175) end,nil)
	return mg:GetClassCount(Card.GetLevel)==1
end
--adjust
function s.desfilter(c,e)
	return not c:IsImmuneToEffect(e) and c:IsDestructable(e)
		and not c:IsSetCard(0x903) and not c:HasLevel()
end
function s.adjustcon(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	local og=Duel.GetOverlayGroup(tp,1,1)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if #og>0 or #g>0 then
		e:GetHandler():CreateEffectRelation(e)
		return true
	end
	return false
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local og=Duel.GetOverlayGroup(tp,1,1)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if #og>0 or #g>0 then
		Duel.Hint(HINT_CARD,0,id)
		if #og>0 then Duel.SendtoGrave(og,REASON_EFFECT,PLAYER_NONE,tp) end
		if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT|REASON_DESTROY,PLAYER_NONE,tp) end
		Duel.Readjust()
	end
end

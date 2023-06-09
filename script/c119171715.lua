--소울 슬레이어-블랑슈
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(aux.FilterBoolFunction(Card.IsSetCard,0x903)),1,1,s.matfilter)
	--synchro summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetOperation(s.synop)
	c:RegisterEffect(e1)
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
--synchro summon
function s.matfilter(c,scard,sumtype,tp)
	return c:IsSetCard(0x903,scard,sumtype,tp)
end
function s.synop(e,tg,ntg,sg,lv,sc,tp)
	local res=(sc:IsCode(id) and sg:GetClassCount(Card.GetLevel)==1 and #sg==2)
		or (not sc:IsCode(id) and sg:CheckWithSumEqual(Card.GetSynchroLevel,lv,#sg,#sg,sc))
	return res,true
end
--adjust
function s.desfilter(c,e)
	return not c:IsImmuneToEffect(e) and c:IsDestructable(e)
		and not c:IsSetCard(0x903) and c:HasLevel()
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

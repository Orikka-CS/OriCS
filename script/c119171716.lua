--소울 슬레이어-느와르
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.xyzfilter,nil,2,nil,nil,nil,nil,false,s.xyzcheck)
	--remove material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.remop)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.destg)
	c:RegisterEffect(e2)
end
s.listed_series={0x903}
function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsSetCard(0x903,xyz,sumtype,tp) and not c:IsXyzLevel(xyz,0)
end
function s.xyzcheck(g,tp,xyz)
	local mg=g:Filter(function(c) return not c:IsHasEffect(511001175) end,nil)
	return mg:GetClassCount(Card.GetLevel)==1
end
--remove material
function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetOverlayGroup(tp,1,1)
	if #g==0 then return end
	Duel.SendtoGrave(g,REASON_EFFECT)
end
--destroy
function s.destg(e,c)
	return not c:IsSetCard(0x903) and not c:HasLevel()
end
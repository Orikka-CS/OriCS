--소울 슬레이어-루쥬
local s,id=GetID()
function s.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.destg)
	c:RegisterEffect(e1)
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
function s.filter(e,c)
	return c:IsSetCard(0x903)
end
function s.matfilter(e,c,sumtype,tp)
	return c:IsSetCard(0x903)
end
function s.destg(e,c)
	return not c:IsSetCard(0x903) and (c:IsLevelBelow(3) or c:IsRankBelow(3) or c:IsLinkBelow(2))
end
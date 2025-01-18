--진압연구형 가이아스 퓨지아스
local s,id=GetID()
function c651.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.mfilter,1,1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(Fusion.SummonEffTG())
	e1:SetOperation(Fusion.SummonEffOP())
	c:RegisterEffect(e1)
end
s.listed_series={0x256a}
s.listed_names={id}
s.material_setcode=0x256a
function s.mfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0x256a,lc,sumtype,tp) and not c:IsSummonCode(lc,sumtype,tp,id)
end
function s.spcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
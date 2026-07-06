--페를라렌트 루베도
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local params={handler=c,matfilter=Fusion.OnFieldMat,extrafil=s.extrafil}
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1(Fusion.SummonEffTG(params)))
	e1:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e1)
end

--effect 1
function s.con1filter(c)
	return c:IsSetCard(0xf41) and c:IsFaceup()
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_ONFIELD,0,nil)>0
end

function s.chainfilter(c)
	return c:IsFaceup() and c:GetEquipCount()>0
end

function s.tg1(fustg)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return fustg(e,tp,eg,ep,ev,re,r,rp,0) end
		if Duel.GetMatchingGroupCount(s.chainfilter,tp,0,LOCATION_MZONE,nil)>0 then
			Duel.SetChainLimit(function(e,ep,tp) return ep==tp end)
		end
		fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end

function s.extrafil(e,tp,mg,sumtype)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup),tp,0,LOCATION_MZONE,nil)
end
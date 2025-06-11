--[ MST ]
local s,id=GetID()
function s.initial_effect(c)

	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,0))
	e9:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e9:SetRange(LOCATION_HAND)
	e9:SetCode(EVENT_CHAIN_SOLVED)
	e9:SetCountLimit(1,id)
	e9:SetProperty(EFFECT_FLAG_DELAY)
	e9:SetCondition(s.spcon1)
	e9:SetTarget(s.sptg)
	e9:SetOperation(s.spop)
	c:RegisterEffect(e9)
	
end

function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsQuickPlaySpell()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
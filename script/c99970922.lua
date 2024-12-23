--[ Bloodress ]
local s,id=GetID()
function s.initial_effect(c)

    -- Name treated as "블러드레스 헬레미아"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetValue(99970921)
    c:RegisterEffect(e1)
	
    -- Substitute Fusion Material
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_FUSION_SUBSTITUTE)
    e2:SetCondition(s.sub_condition)
	e2:SetValue(function(e,fc) return fc:IsSetCard(0xad6f) end)
    c:RegisterEffect(e2)
	
    -- Special Summon when "Bloodless" Monster Destroyed
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
    e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND)
    e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e3:SetCountLimit(1,id)
	e3:SetCondition(s.condition)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
	
end

s.listed_names={99970921}

function s.sub_condition(e)
    return e:GetHandler():IsLocation(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_ONFIELD)
end

function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousSetCard(0xad6f) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
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

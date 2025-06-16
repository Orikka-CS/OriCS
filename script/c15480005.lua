--오성신 강림
local s,id=GetID()
function s.initial_effect(c)
	Ritual.AddProcGreater({handler=c,filter=s.tfil11,lv=Card.GetAttack,matfilter=s.tfil12,
		location=LOCATION_HAND+LOCATION_GRAVE,requirementfunc=Card.GetAttack})
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
s.listed_names={15480009}
function s.tfil11(c)
	return c:GetAttack()>0 and c:GetType()&(TYPE_RITUAL+TYPE_MONSTER)==(TYPE_RITUAL+TYPE_MONSTER) and c:IsCode(15480009)
end
function s.tfil12(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:GetAttack()>0
end
function s.tfil2(c,e,tp)
	return c:IsSetCard(0xffe) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tfil2,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>=5
			and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and g:GetClassCount(Card.GetAttribute)>=5
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,5,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<5 then
		return
	end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		return
	end
	local g=Duel.GetMatchingGroup(s.tfil2,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	local tg=aux.SelectUnselectGroup(g,e,tp,5,5,aux.dpcheck(Card.GetAttribute),1,tp,HINTMSG_SPSUMMON)
	if tg and #tg==5 then
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
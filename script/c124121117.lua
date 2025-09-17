--청명한 폭포의 요화
local s,id=GetID()
function s.initial_effect(c)
	local params={matfilter=aux.FilterBoolFunction(Card.IsSetCard,0xfa7),gc=Fusion.ForcedHandler}
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(Fusion.SummonEffTG(params))
	e1:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_TOHAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(s.con3)
	c:RegisterEffect(e3)
end
s.listed_series={0xfa7}
s.listed_names={124121114}
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()&(PHASE_MAIN1|PHASE_MAIN2)~=0
end
function s.tfil21(c,e,tp)
	return c:IsCode(124121114) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tfil22(c)
	return c:IsFaceup() and c:IsMonster() and c:IsAbleToHand()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.tfil21,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b2=Duel.IsExistingMatchingCard(s.tfil22,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,nil)
	if chk==0 then
		return b1 or b2
	end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
			return
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tfil21),tp,
			LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tfil22),tp,0,
			LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			local p=tp
			if tc:IsAbleToExtra() then
				p=nil
			end
			Duel.SendtoHand(g,p,REASON_EFFECT)
		end
	end
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and (r&REASON_FUSION)==REASON_FUSION
end
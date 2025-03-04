--[ Anemoi ]
local s,id=GetID()
function s.initial_effect(c)

	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.anemoi)
	
	local e99=MakeEff(c,"S","M")
	e99:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e99:SetCode(EFFECT_IMMUNE_EFFECT)
	e99:SetValue(function(e,te) return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) end)
	e99:SetCondition(function(e) return Duel.GetCustomActivityCount(id,e:GetHandlerPlayer(),ACTIVITY_CHAIN)>0 end)
	c:RegisterEffect(e99)

	local e1=MakeEff(c,"FTo","H")
	e1:SetD(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCL(1,id)
	WriteEff(e1,1,"NTO")
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"STo")
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	
end

function s.anemoi(re,tp,cid)
	local rc=re:GetHandler()
	return not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and rc:IsCode(99970559,99970563))
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_ONFIELD)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then 
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.tar2fil(c,e,tp,ft)
	return c:IsSetCard(0xad70) and c:IsMonster() and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return Duel.IsExistingMatchingCard(s.tar2fil,tp,LOCATION_DECK,0,1,nil,e,tp,ft)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,tp,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.tar2fil,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft):GetFirst()
	if sc then
		if aux.ToHandOrElse(sc,tp,
			function(sc) return ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
			function(sc) return Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) end,
			aux.Stringid(id,1)
		)>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		end
	end
end

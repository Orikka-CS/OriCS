--[ Deadmoon ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=MakeEff(c,"A")
	e1:SetD(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"Qo","G")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCost(Cost.SelfBanish)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	
end

function s.tar1f(c,e,tp)
	return c:IsCode(99971031) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())
		and Duel.IsExistingMatchingCard(s.tar1f,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tar1f),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsCode,99971031),tp,LOCATION_MZONE,0,nil)
		if ct>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
			local sg=Duel.SelectMatchingCard(tp,Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,ct,nil)
			if #sg==0 then return end
			for tc in sg:Iter() do
				tc:NegateEffects(e:GetHandler(),RESET_PHASE|PHASE_END,true)
			end
		end
	end
end

function s.chfilter1(c,tp)
	return c:GetSequence()<5
		and Duel.IsExistingMatchingCard(s.chfilter2,tp,LOCATION_MZONE,0,1,c)
end
function s.chfilter2(c)
	return c:GetSequence()<5
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.chfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g1=Duel.SelectMatchingCard(tp,s.chfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc1=g1:GetFirst()
	if not tc1 then return end
	Duel.HintSelection(g1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g2=Duel.SelectMatchingCard(tp,s.chfilter2,tp,LOCATION_MZONE,0,1,1,tc1)
	Duel.HintSelection(g2)
	local tc2=g2:GetFirst()
	Duel.SwapSequence(tc1,tc2)
end

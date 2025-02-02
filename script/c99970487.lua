--[ Insomnia ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=MakeEff(c,"A")
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCL(1,id,YuL.O)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
end

function s.tar1fil(c)
	return c:IsSetCard(0xe0a) and c:IsMonster() and c:IsAbleToGrave()
end
function s.op1fil2(c)
	return c:IsFaceup() and c:IsSetCard(0xe0a) and c:IsRace(RACE_ZOMBIE)
end
function s.op1fil(c,e,tp)
	return ((c:IsSetCard(0xe0a) and c:IsControler(tp))
		or (Duel.IsExistingMatchingCard(s.op1fil2,tp,LOCATION_MZONE,0,1,nil)))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar1fil,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,s.tar1fil,tp,LOCATION_DECK,0,1,1,nil)
	if #g1>0 and Duel.SendtoGrave(g1,REASON_EFFECT)>0 and g1:GetFirst():IsLocation(LOCATION_GRAVE) then
		local g2=Duel.GetMatchingGroup(s.op1fil,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tc=g2:Select(tp,1,1,nil):GetFirst()
			Duel.BreakEffect()
			if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_CHANGE_RACE)
				e1:SetValue(RACE_ZOMBIE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end

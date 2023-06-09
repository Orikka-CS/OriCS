--소울 슬레이어의 군세
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--Oath
	Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,s.counterfilter)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.listed_series={0x903}
s.listed_names={id}
--Activity Counter
function s.counterfilter(c)
	return c:IsSetCard(0x903)
end
--Oath
function s.cfil1(c,tp)
	return (c:IsPublic() or c:IsFaceup()) and c:IsMonster() and c:IsSetCard(0x903) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
		and Duel.IsExistingMatchingCard(s.cfil1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp) end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfil1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
--Target
function s.splimit(e,c)
	return not c:IsSetCard(0x903)
end
function s.tfil1(c,e,tp)
	return c:IsSetCard(0x903) and 
		((c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
			or (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()) or c:IsAbleToHand())
end
function s.tff1(c)
	return not c:IsAbleToHand() and c:IsMonster()
end
function s.tff2(c)
	return not c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.tfun1(sg,e,tp,mg)
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft1=math.min(ft1,1) end
	local c1=sg:FilterCount(s.tff1,nil)
	local c2=sg:FilterCount(s.tff2,nil)
	local c3=sg:GetClassCount(Card.GetCode)
	return c3==2 and c1<=ft1 and c2<=ft2
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tfil1,tp,LOCATION_DECK,0,nil,e,tp)
	if chk==0 then
		return aux.SelectUnselectGroup(g,e,tp,2,2,s.tfun1,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
--Operation
function s.setfilter(c)
	if c:IsMonster() then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
	elseif c:IsType(TYPE_SPELL+TYPE_TRAP) then
		return c:IsSSetable()
	end
	return false
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft1=math.min(ft1,1) end
	local g=Duel.GetMatchingGroup(s.tfil1,tp,LOCATION_DECK,0,nil,e,tp)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.tfun1,1,tp,HINTMSG_ATOHAND)
	if #sg~=2 then return end
	--first card
	local tc=sg:Select(tp,1,1,nil):GetFirst()
	aux.ToHandOrElse(tc,tp,function(c)
			if tc:IsMonster() then
				return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
					and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
			elseif tc:IsType(TYPE_SPELL+TYPE_TRAP) then
				return tc:IsSSetable()
			end
			return false
		end,
	function(c)
			if tc:IsMonster() then
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
				ft1=ft1-1
			else
				Duel.SSet(tp,tc)
				ft2=ft2-1
			end
		end,1153)
	--second card
	tc=(sg-tc):Select(tp,1,1,nil):GetFirst()
	aux.ToHandOrElse(tc,tp,function(c)
			if tc:IsMonster() then
				return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
					and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
			elseif tc:IsType(TYPE_SPELL+TYPE_TRAP) then
				return tc:IsSSetable()
			end
			return false
		end,
	function(c)
			if tc:IsMonster() then
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
				ft1=ft1-1
			else
				Duel.SSet(tp,tc)
				ft2=ft2-1
			end
		end,1153)
	Duel.SpecialSummonComplete()
	Duel.ConfirmCards(1-tp,sg)
end

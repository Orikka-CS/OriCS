--인조천사 인두스트리아
local s,id=GetID()
function s.initial_effect(c)
	--이 카드의 일반 소환을 실행한다.
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_SUMMON)
	e1a:SetType(EFFECT_TYPE_QUICK_O)
	e1a:SetCode(EVENT_FREE_CHAIN)
	e1a:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1a:SetRange(LOCATION_HAND)
	e1a:SetCountLimit(1,id)
	e1a:SetCondition(s.Synthetic_Seraphim_Condition1)
	e1a:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk) e:SetSpellSpeed(3) return true end)
	e1a:SetTarget(s.Synthetic_Seraphim_Target)
	e1a:SetOperation(s.Synthetic_Seraphim_Operation)
	c:RegisterEffect(e1a)
	--서로의 필드에 "인조천사 토큰"(천사족 / 빛 / 레벨 1 / 공격력 300 / 수비력 300)을 1장씩 특수 소환한다.
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk) e:SetSpellSpeed(3) return true end)
	e2a:SetTarget(s.tktg)
	e2a:SetOperation(s.tkop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2b)
	local e2c=e2a:Clone()
	e2c:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2c)
	--제외한 수만큼, 덱에서 "인조천사" 카드를 패에 넣는다(같은 이름의 카드는 1장까지).
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk) e:SetSpellSpeed(3) return true end)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_names={16946850}
s.listed_series={0xc12}
function s.Synthetic_Seraphim_Filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.Synthetic_Seraphim_Condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		or Duel.IsExistingMatchingCard(s.Synthetic_Seraphim_Filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.Synthetic_Seraphim_Target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSummonable(true,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,tp,0)
end
function s.Synthetic_Seraphim_Operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Summon(tp,c,true,nil)~=0 then
		--이 효과로 일반 소환한 이 카드를 싱크로 소재로 할 경우, 이 카드를 튜너 이외의 몬스터로 취급할 수 있다.
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_NONTUNER)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e1)
	end
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,16946850,0,TYPES_TOKEN,300,300,1,RACE_FAIRY,ATTRIBUTE_LIGHT)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,16946850,0,TYPES_TOKEN,300,300,1,RACE_FAIRY,ATTRIBUTE_LIGHT,1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,16946850,0,TYPES_TOKEN,300,300,1,RACE_FAIRY,ATTRIBUTE_LIGHT)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,16946850,0,TYPES_TOKEN,300,300,1,RACE_FAIRY,ATTRIBUTE_LIGHT,1-tp) then
		local tk1=Duel.CreateToken(tp,16946850)
		local tk2=Duel.CreateToken(tp,16946850)
		Duel.SpecialSummonStep(tk1,0,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummonStep(tk2,0,tp,1-tp,false,false,POS_FACEUP)
		Duel.SpecialSummonComplete()
	end
end
function s.cfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost()
end
function s.filter(c)
	return (c:IsCode(16946849) or c:IsCode(16946850) or c:IsSetCard(0xc12)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	local dg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	local ct=math.min(2,dg:GetClassCount(Card.GetCode))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,ct,nil)
	local rc=Duel.Remove(rg,POS_FACEUP,REASON_COST)
	Duel.SetTargetParam(rc)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,rc,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if dg:GetClassCount(Card.GetCode)==0 or dg:GetClassCount(Card.GetCode)<ct then return end
	local sg=aux.SelectUnselectGroup(dg,e,tp,ct,ct,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
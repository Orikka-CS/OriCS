--피스펙터 프라임
local s,id=GetID()
function s.initial_effect(c)
	--자신 필드의 몬스터가, 존재하지 않을 경우 또는 기계족 몬스터뿐일 경우, 이 카드는 패에서 특수 소환할 수 있다.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--"피스펙터 프라임"이 아닌, 이하의 카드 중 어느 1장을 덱에서 패에 넣는다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
s.listed_series={0xc18,0xc17}
s.listed_names={id}
function s.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_MACHINE)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil))
end
function s.thfilter(c)
	return ((c:IsSetCard(0xc18) and c:IsType(TYPE_MONSTER)) or (c:IsSetCard(0xc17) and c:IsType(TYPE_SPELL+TYPE_TRAP)))
		and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sp_chk=re and e:GetHandler():IsSpecialSummoned() and ((re:IsMonsterEffect() and re:GetHandler():IsSetCard(0xc18)) or (re:IsSpellTrapEffect() and re:GetHandler():IsSetCard(0xc17)))
	local loc=LOCATION_DECK|(sp_chk and LOCATION_GRAVE or 0)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,loc,0,1,nil) end
	e:SetLabel(sp_chk and 1 or 0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,loc)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local sp_chk=e:GetLabel()==1
	local loc=LOCATION_DECK|(sp_chk and LOCATION_GRAVE or 0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,loc,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--체레넬라제 르보테
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.cst1filter(c)
	return c:IsCode(124161426) and c:IsAbleToGraveAsCost()
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE):GetFirst()
	if sg:IsLocation(LOCATION_HAND) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	Duel.SendtoGrave(sg,REASON_COST)
end

function s.tg1filter(c)
	return c:IsSetCard(0xf3b) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	if e:GetLabel()==1 then
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	end
end

function s.op1spfilter(c,e,tp)
	return c:IsSetCard(0xf3b) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,sg)
			local spg=Duel.GetMatchingGroup(s.op1spfilter,tp,LOCATION_HAND,0,nil,e,tp)
			if e:GetLabel()==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #spg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.BreakEffect()
				local spsg=aux.SelectUnselectGroup(spg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
				Duel.SpecialSummon(spsg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

--effect 2
function s.tg2ctfilter(c)
	return c:IsSetCard(0xf3b)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.tg2ctfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return ct>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=ct end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,ct,1-tp,LOCATION_DECK)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.tg2ctfilter,tp,LOCATION_GRAVE,0,nil)
	if ct>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=ct then
		local g=Duel.GetDecktopGroup(1-tp,ct)
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
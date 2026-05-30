--브릿지버스터 카사이
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e2a=e2:Clone()
	e2a:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2a)
end

--effect 1
function s.con1filter(c,tp)
	return c:IsMonster() and c:IsControler(1-tp) and c:IsLocation(LOCATION_GRAVE)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con1filter,nil,tp)>1
end

function s.tg1filter(c,tp)
	return c:IsMonster() and c:IsControler(1-tp) and c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=eg:Filter(s.tg1filter,nil,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(s.tg1filter,nil,tp)
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and #g>0 then
			Duel.BreakEffect()
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end

--effect 2
function s.tg2filter(c)
	return c:IsSetCard(0xf3e) and not c:IsCode(id) and c:IsAbleToGrave()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_MZONE)
end

function s.op2hfilter(c)
	return c:IsSetCard(0xf3e) and c:IsAbleToGrave()
end

function s.op2rfilter(c)
	return c:IsMonster() and c:IsAbleToHand()
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
		if Duel.SendtoGrave(sg,REASON_EFFECT)>0 then
			local hg=Duel.GetMatchingGroup(s.op2hfilter,tp,LOCATION_HAND,0,nil)
			local rg=Duel.GetMatchingGroup(s.op2rfilter,tp,0,LOCATION_MZONE,nil)
			if #hg>0 and #rg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.BreakEffect()
				local hsg=aux.SelectUnselectGroup(hg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
				if Duel.SendtoGrave(hsg,REASON_EFFECT)>0 then
					local rsg=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_RTOHAND)
					Duel.SendtoHand(rsg,nil,REASON_EFFECT)
				end
			end
		end
	end
end
--피르티리오 도그
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c,e,tp)
	return c:IsSetCard(0xf21) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_HAND,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_HAND)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_HAND,0,nil,e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 then 
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.BreakEffect()
		local dis=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
		Duel.SetTargetParam(dis)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetOperation(function(e) return e:GetLabel() end)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		e1:SetLabel(Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM))
		Duel.RegisterEffect(e1,tp)
	end
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return 5-Duel.GetLocationCount(tp,LOCATION_MZONE)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 or 5-Duel.GetLocationCount(1-tp,LOCATION_MZONE)-Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)>0
end

function s.tg2filter(c)
	return c:IsSetCard(0xf21) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToHand()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end

function s.op2filter(c)
	return c:IsAbleToGrave()
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,sg)
			Duel.BreakEffect()
			local dg=Duel.GetMatchingGroup(s.op2filter,tp,LOCATION_HAND,0,nil)
			local dsg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
			Duel.SendtoGrave(dsg,REASON_EFFECT)
		end
	end
end
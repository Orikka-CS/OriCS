--나우프라테 킬 키테라
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_MONSTER+TYPE_EFFECT,0,2100,5,RACE_ZOMBIE,ATTRIBUTE_WATER,POS_FACEUP,tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and s.tg1(e,tp,eg,ep,ev,re,r,rp,0) then
		c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
		Duel.SpecialSummonStep(c,1,tp,tp,true,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetProperty(EFFECT_FLAG_DELAY)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_SZONE) end)
		e1:SetTarget(s.op1tg)
		e1:SetOperation(s.op1op)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
		c:AddMonsterAttributeComplete()
	end
	Duel.SpecialSummonComplete()
end

function s.op1tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_MZONE)
end

function s.op1atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf28)
end

function s.op1desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end

function s.op1op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.op1atkfilter,tp,LOCATION_MZONE,0,c)
	if #g>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=g:GetSum(Card.GetAttack)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		Duel.AdjustInstantly(c)
		local dg=Duel.GetMatchingGroup(s.op1desfilter,tp,0,LOCATION_MZONE,nil,c:GetAttack())
		if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local dsg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DESTROY)
			Duel.Destroy(dsg,REASON_EFFECT)
		end
	end
end

--effect 2
function s.tg2filter(c)
	return c:IsSetCard(0xf28) and c:IsMonster() and c:IsAbleToHand() 
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_DECK)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
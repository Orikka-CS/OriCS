--트라비니카 제스쳐
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--count
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetCondition(s.cntcon)
		ge1:SetOperation(s.cntop1)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_CHAIN_NEGATED)
		ge2:SetCondition(s.cntcon)
		ge2:SetOperation(s.cntop2)
		Duel.RegisterEffect(ge2,0)
	end)
end

--count
function s.cntcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and (re:GetActivateLocation()&LOCATION_ONFIELD)~=0
end

function s.cntop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(rp,id,RESET_PHASE+PHASE_END,0,1)
end

function s.cntop2(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFlagEffect(rp,id)
	if ct>0 then
		Duel.ResetFlagEffect(rp,id)
		for i=1,ct-1 do
			Duel.RegisterFlagEffect(rp,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end

--effect 1
function s.tg1filter(c)
	return c:IsSetCard(0xf3c) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.op1spfilter(c,e,tp)
	return c:IsSetCard(0xf3c) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.op1setfilter(c)
	return c:IsSetCard(0xf3c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		if Duel.GetFlagEffect(tp,id)==0 then
			local mg=Duel.GetMatchingGroup(s.op1spfilter,tp,LOCATION_HAND,0,nil,e,tp)
			local stg=Duel.GetMatchingGroup(s.op1setfilter,tp,LOCATION_HAND,0,nil)
			local b1=true
			local b2=#mg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			local b3=#stg>0
			if b2 or b3 then
				Duel.BreakEffect()
				local b=Duel.SelectEffect(tp,
					{b1,aux.Stringid(id,0)},
					{b2,aux.Stringid(id,1)},
					{b3,aux.Stringid(id,2)})
				if b==2 then
					local spg=aux.SelectUnselectGroup(mg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
					Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
				elseif b==3 then
					local setg=aux.SelectUnselectGroup(stg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SET):GetFirst()
					Duel.SSet(tp,setg)
					if setg then
						local e1=Effect.CreateEffect(e:GetHandler())
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
						e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						setg:RegisterEffect(e1)
						local e2=e1:Clone()
						e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
						setg:RegisterEffect(e2)
					end
				end
			end
		end
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsType(TYPE_EFFECT)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,tp)>0
end

function s.tg2filter(c,e)
	return c:IsAbleToGrave() and c:IsCanBeEffectTarget(e)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_RELEASE)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,sg,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg then
		Duel.SendtoGrave(tg,REASON_EFFECT+REASON_RELEASE)
	end
end
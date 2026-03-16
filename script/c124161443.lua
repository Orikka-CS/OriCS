--트라비니카 리펜턴스
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.con0)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
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

--activate
function s.con0(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end

--effect 1
function s.cst1filter(c)
	return c:IsReleasable()
end

function s.tg1filter(c,e,tp)
	return c:IsSetCard(0xf3c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.cst1con(sg,e,tp,mg)
	local dg=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil,e,tp)
	return dg:GetClassCount(Card.GetCode)>=#sg and Duel.GetMZoneCount(tp,sg)>=#sg
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_MZONE,0,nil)
	local dg=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil,e,tp)
	local max_ct=dg:GetClassCount(Card.GetCode)
	if chk==0 then return #g>0 and max_ct>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,max_ct,s.cst1con,1,tp,HINTMSG_RELEASE)
	local ct=Duel.Release(sg,REASON_COST)
	e:SetLabel(ct)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,e:GetLabel(),tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.op1ffilter(c)
	return c:IsSetCard(0xf3c) and c:IsType(TYPE_FUSION) and c:IsFaceup()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil,e,tp)
	if #g>=ct then
		local sg=aux.SelectUnselectGroup(g,e,tp,ct,ct,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
		if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
			local fg=Duel.GetMatchingGroupCount(s.op1ffilter,tp,LOCATION_MZONE,0,nil)
			local dg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
			if fg>0 and #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.BreakEffect()
				local dsg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
				Duel.SendtoDeck(dsg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end
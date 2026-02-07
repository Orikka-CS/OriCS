--뮬베이릿 얼루어
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.cst1filter(c)
	return c:IsMonster() and c:IsType(TYPE_EFFECT) and c:IsAbleToRemoveAsCost()
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end

function s.tg1filter1(c,e,tp)
	return c:IsSetCard(0xf3a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tg1filter2(c)
	return c:IsSetCard(0xf3a) and c:IsReleasable()
end

function s.tg1filter3(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsControlerCanBeChanged()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetMatchingGroupCount(s.tg1filter1,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil,e,tp)>0
	local b2=Duel.GetMatchingGroupCount(s.tg1filter2,tp,LOCATION_MZONE,0,nil)>0 and Duel.GetMatchingGroupCount(s.tg1filter3,tp,0,LOCATION_MZONE,nil)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>0
	if chk==0 then return b1 or b2 end
	local b=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	e:SetLabel(b)
	if b==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
	else
		e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_CONTROL)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
	end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local b=e:GetLabel()
	if b==1 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local g=Duel.GetMatchingGroup(s.tg1filter1,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil,e,tp)
		if #g>0 then
			local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif b==2 then
		local g1=Duel.GetMatchingGroup(s.tg1filter2,tp,LOCATION_MZONE,0,nil)
		if #g1>0 then
			local sg1=aux.SelectUnselectGroup(g1,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_RELEASE)
			if Duel.SendtoGrave(sg1,REASON_EFFECT+REASON_RELEASE)>0 then
				local g2=Duel.GetMatchingGroup(s.tg1filter3,tp,0,LOCATION_MZONE,nil)
				if #g2>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
					Duel.BreakEffect()
					local sg2=aux.SelectUnselectGroup(g2,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONTROL)
					Duel.GetControl(sg2,tp)
				end
			end
		end
	end
end

--effect 2
function s.cst2filter(c)
	return c:IsSetCard(0xf3a) and c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost()
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_REMOVED,0,nil)
	if chk==0 then return #g>1 end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.TRUE,1,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end
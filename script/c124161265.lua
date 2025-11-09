--메가히트 헤이터 로리나
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e2a=e2:Clone()
	e2a:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2a)
end

--effect 1
function s.con1filter(c)
	return c:IsSetCard(0xf31) and c:IsFaceup()
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_ONFIELD,0,nil)
	return g>0 and Duel.IsMainPhase()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.op1filter(c)
	return c:IsTrap() and c:IsSetCard(0xf31) and c:IsSSetable()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
	if c:IsRelateToEffect(e) and (b1 or b2) then
		local b=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
		if b==1 then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		else
			Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP)
			local g=Duel.GetMatchingGroup(s.op1filter,tp,LOCATION_DECK,0,nil)
			if #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.BreakEffect()
				local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SET)
				Duel.SSet(tp,sg)
			end
		end
	end
end

--effect 2
function s.op2filter(c)
	return c:IsSetCard(0xf31) and not c:IsCode(id)
end

function s.op2dfilter(c)
	return c:IsSetCard(0xf31) and c:IsType(TYPE_LINK) and c:IsFaceup()
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local own=e:GetHandler():GetOwner()
	local g=Duel.GetMatchingGroup(s.op2filter,own,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,own,1,1,aux.TRUE,1,own,HINTMSG_DESTROY)
		Duel.Destroy(sg,REASON_EFFECT)
		local cg=Duel.GetMatchingGroup(s.op2dfilter,tp,0,LOCATION_MZONE,e:GetHandler())
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,e:GetHandler())
		if #cg>0 and #dg>1 then
			Duel.BreakEffect()
			local dsg=aux.SelectUnselectGroup(dg,e,tp,2,2,aux.TRUE,1,tp,HINTMSG_DESTROY)
			Duel.Destroy(dsg,REASON_EFFECT)
		end
	end
end
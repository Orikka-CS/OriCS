--볼틱갭츠 오버커런트
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c)
	return c:IsSetCard(0xf37) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,LOCATION_MZONE)
end

function s.op1atkfilter(c)
	return c:IsFaceup() and c:IsLinked()
end

function s.op1ctfilter(c)
	return c:IsSetCard(0xf37) and c:IsFaceup()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		local ag=Duel.GetMatchingGroup(s.op1atkfilter,tp,LOCATION_MZONE,0,nil)
		if #ag>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local asg=aux.SelectUnselectGroup(ag,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATKDEF):GetFirst()
			asg:UpdateAttack(Duel.GetMatchingGroupCount(s.op1ctfilter,tp,LOCATION_ONFIELD,0,nil)*500,nil,e:GetHandler())
		end
	end
end

--effect 2
function s.cst2filter(c)
	return c:IsSetCard(0xf37) and c:IsAbleToRemoveAsCost()
end

function s.tg2filter(c,e,tp,lk)
	return c:IsSetCard(0xf37) and c:IsType(TYPE_LINK) and c:IsLink(lk) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_GRAVE,0,c)   
	if chk==0 then
		if not c:IsAbleToRemoveAsCost() then return false end
		for i=1,6 do
			if #g>=i-1 and Duel.IsExistingMatchingCard(s.tg2filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,i) then
				return true
			end
		end
		return false
	end
	local nums={}
	for i=1,6 do
		if #g>=i-1 and Duel.IsExistingMatchingCard(s.tg2filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,i) then
			table.insert(nums,i)
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local ct=Duel.AnnounceNumber(tp,table.unpack(nums))
	local sg=nil
	if ct>1 then
		sg=aux.SelectUnselectGroup(g,e,tp,ct-1,ct-1,aux.TRUE,1,tp,HINTMSG_REMOVE)
	else
		sg=Group.CreateGroup()
	end
	sg:AddCard(c)
	
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	e:SetLabel(ct)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_EXTRA,0,nil,e,tp,ct)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
		local sc=sg:GetFirst()
		if sc then
			sc:SetMaterial(nil)
			if Duel.SpecialSummon(sc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)>0 then
				sc:CompleteProcedure()
			end
		end
	end
end
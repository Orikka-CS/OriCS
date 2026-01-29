--[ Stateshifter ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=MakeEff(c,"Qo","MH")
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCL(1,id)
	WriteEff(e1,1,"NCT")
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.NegateEffect(ev) end)
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"F","M")
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetCondition(function(e) return s[0]==TYPE_MONSTER end)
	e2:SetTarget(function(e,c) return c~=e:GetHandler() end)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	
	local e3=MakeEff(c,"FC","R")
	e3:SetCode(EVENT_ADJUST)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	WriteEff(e3,3,"O")
	c:RegisterEffect(e3)
	
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		aux.AddValuesReset(function()
			s[0]=0
			s[1]=0
		end)
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
	
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	s[1]=s[0]
	s[0]=re:GetActiveType()&0x7
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsMonsterEffect() and Duel.IsChainDisablable(ev)
end
function s.cost1f(c)
	return c:IsSetCard(0x5d72) and c:IsAbleToRemoveAsCost(POS_FACEDOWN) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost(POS_FACEDOWN) and 
		Duel.IsExistingMatchingCard(s.cost1f,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cost1f,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,c)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (rp~=tp and s[1]==TYPE_SPELL and s[0]==TYPE_MONSTER
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummon(tp) and c:IsFacedown()
		and (not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,id),tp,LOCATION_ONFIELD,0,1,nil))) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local sg=g:Select(tp,1,3,nil)
			Duel.BreakEffect()
			Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)
		end
	end
end

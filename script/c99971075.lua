--[ Stateshifter ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=MakeEff(c,"Qo","H")
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCL(1,id)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"FTo","M")
	e2:SetD(id,1)
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_SET)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCL(1)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	
	local e3=MakeEff(c,"FC","R")
	e3:SetCode(EVENT_ADJUST)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	WriteEff(e3,3,"NO")
	c:RegisterEffect(e3)
	
	aux.GlobalCheck(s,function()
		s[0]=0
		aux.AddValuesReset(function()
			s[0]=0
		end)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e4:SetCode(EVENT_CHAINING)
		e4:SetOperation(s.checkop)
		Duel.RegisterEffect(e4,0)
	end)
	
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local temp=re:GetActiveType()&0x7
	local p=e:GetHandlerPlayer()
	if rp~=p and s[0]==TYPE_MONSTER and temp==TYPE_TRAP then
		Duel.RegisterFlagEffect(p,id,RESET_PHASE|PHASE_END,0,1)
	end
	s[0]=temp
end

function s.cost1f(c)
	return c:IsAbleToRemoveAsCost(POS_FACEDOWN) and c:IsSetCard(0x5d72)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cost1f,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cost1f,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)
end

function s.con2f(c)
	return c:IsFacedown() and not c:IsType(TYPE_TOKEN)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.con2f,1,nil)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sg=Duel.SelectMatchingCard(tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,0,1,nil)
	if #sg>0 then
		Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
	end
end

function s.con3(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummon(tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsFacedown()
		and (not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,id),tp,LOCATION_ONFIELD,0,1,nil))
		and Duel.HasFlagEffect(tp,id,1)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if (not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,id),tp,LOCATION_ONFIELD,0,1,nil))
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.ResetFlagEffect(tp,id)
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			local sg=aux.SelectUnselectGroup(g,e,tp,1,2,aux.TRUE,1,tp,HINTMSG_REMOVE)
			Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end

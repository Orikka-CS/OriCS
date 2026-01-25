--[ Stateshifter ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"STo")
	e2:SetCategory(CATEGORY_SET)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCL(1,id)
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
	if rp~=p and s[0]==TYPE_SPELL and temp==TYPE_TRAP then
		Duel.RegisterFlagEffect(p,id,RESET_PHASE|PHASE_END,0,1)
	end
	s[0]=temp
end

function s.con1(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,e:GetHandler())
	return aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,e:GetHandler())
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
	g:DeleteGroup()
end

function s.tar2f(c)
	return c:IsSetCard(0x5d72) and c:IsSpellTrap() and c:IsSSetable() and (c:IsLocation(LOCATION_DECK) or c:IsFacedown())
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar2f,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,nil) end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.tar2f,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
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
function s.op3f(c)
	return c:IsNegatable() and c:IsST()
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if (not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,id),tp,LOCATION_ONFIELD,0,1,nil))
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.ResetFlagEffect(tp,id)
		if Duel.IsExistingMatchingCard(s.op3f,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			local g=Duel.SelectMatchingCard(tp,s.op3f,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			Duel.BreakEffect()
			Duel.HintSelection(tc,true)
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESETS_STANDARD)
				tc:RegisterEffect(e3)
			end
		end
	end
end

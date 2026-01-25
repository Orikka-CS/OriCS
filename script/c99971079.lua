--[ Stateshifter ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=MakeEff(c,"A")
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetValue(function(e,c) e:SetLabel(1) end)
	e2:SetCondition(function(e)
		local c=e:GetHandler()
		local tp=e:GetHandlerPlayer()
		return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,c,tp,POS_FACEDOWN)
	end)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	
end

function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local lo=e:GetLabelObject()
	if chk==0 then lo:SetLabel(0) return true end
	if lo:GetLabel()==1 then
		e:SetLabel(0x10000)
		lo:SetLabel(0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,c,tp,POS_FACEDOWN)
		Duel.Remove(g,POS_FACEDOWN,REASON_COST)
	else
		e:SetLabel(0)
		lo:SetLabel(0)
	end
end
function s.tar1f(c,e,tp,ft)
	return c:IsSetCard(0x5d72) and c:IsMonster() and (c:IsAbleToRemove(tp,POS_FACEDOWN) or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return Duel.IsExistingMatchingCard(s.tar1f,tp,LOCATION_DECK,0,1,nil,e,tp,ft)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local tc=Duel.SelectMatchingCard(tp,s.tar1f,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft):GetFirst()
	if not tc then return end
	local b1=tc:IsAbleToRemove(tp,POS_FACEDOWN)
	local b2=(ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false))
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	if op==1 then
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	elseif op==2 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

--[ ChaoticWing ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"I","G")
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
	
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==0
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.tar)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.efil)
	Duel.RegisterEffect(e2,tp)
end
function s.tar(e,c)
	return c:IsSetCard(0xcd70)
end
function s.efil(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end

function s.op2fil(c,e,tp,code)
	return c:ListsCode(code) and c:IsSetCard(0xcd70) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar2fil(c,e,tp)
	return c:IsCode(CARD_CYCLONE,CARD_CYCLONE_GALAXY,CARD_CYCLONE_COSMIC,CARD_CYCLONE_DOUBLE,CARD_CYCLONE_DICE)
		and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.op2fil,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=100 then e:SetLabel(0) return false end
		return c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.tar2fil,tp,LOCATION_GRAVE,0,1,c,e,tp)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.tar2fil,tp,LOCATION_GRAVE,0,1,1,c,e,tp)
	e:SetLabelObject(g:GetFirst())
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabelObject():GetCode()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.op2fil,tp,LOCATION_DECK,0,1,1,nil,e,tp,code)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

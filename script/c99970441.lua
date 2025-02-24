--[ The Throne of Destiny ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCL(1,id,YuL.O)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"I","G")
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetCost(aux.bfgcost)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	
end

function s.tarfil(c,e,tp)
	return c:IsSetCard(0x9d70) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.tarfil,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.tarfil,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.tar2fil(c)
	return c:IsFaceup() and c:IsSetCard(0x9d70) and c:IsLevelAbove(3)
end
function s.tar2fil2(c)
	return c:IsSpellTrap() and c:IsAbleToRemove()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar2fil,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.tar2fil2,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.tar2fil,tp,LOCATION_MZONE,0,1,nil)
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.tar2fil2,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,ct,nil)
		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end

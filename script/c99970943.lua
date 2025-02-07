--[ MHR ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=MakeEff(c,"I","HMG")
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCL(1,id)
	e1:SetCost(aux.bfgcost)
	e1:SetCondition(function(e) return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),99970947) end)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(function(e) return Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),99970947) end)
	c:RegisterEffect(e2)
	
	local e3=MakeEff(c,"Qf","R")
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCL(1,{id,1})
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)

end

function s.tar1fil(c,e,tp)
	return c:IsSetCard(0x3d70) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsFaceup()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.tar1fil,tp,LSTN("HGR"),0,1,e:GetHandler(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LSTN("HGR"))
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tar1fil),tp,LSTN("HGR"),0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsSetCard(0x3d70) and rp==tp and re:IsMonsterEffect() and re:GetHandler()~=e:GetHandler()
		and re:GetActivateLocation()&LSTN("HMG")>0
end
function s.tar3fil(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.tar3fil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local isLuci=POS_FACEUP_DEFENSE
	if re:GetHandler():IsCode(99970946) then isLuci=POS_FACEDOWN_DEFENSE end
	
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)~=0 then
		local g1=Duel.GetMatchingGroup(s.tar3fil,tp,LOCATION_MZONE,0,nil)
		local g2=Duel.GetMatchingGroup(s.tar3fil,tp,0,LOCATION_MZONE,nil)
		if #g1>0 or #g2>0 then
			Duel.BreakEffect()
			Duel.ChangePosition(g1,POS_FACEUP_DEFENSE)
			Duel.ChangePosition(g2,isLuci)
		end
	end
end

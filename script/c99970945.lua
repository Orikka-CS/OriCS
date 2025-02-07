--[ MHR ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=MakeEff(c,"I","HMG")
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
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
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_DRAW)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCL(1,{id,1})
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)

end

function s.tar1fil(c)
	return c:IsSetCard(0x3d70) and c:IsFaceup() and c:IsAbleToGrave()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar1fil,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_REMOVED)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tar1fil,tp,LOCATION_REMOVED,0,nil)
	if #g>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:Select(tp,1,2,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)
	end
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsSetCard(0x3d70) and rp==tp and re:IsMonsterEffect() and re:GetHandler()~=e:GetHandler() and re:GetHandler()~=e:GetHandler()
		and re:GetActivateLocation()&LSTN("HMG")>0
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local isLuci=POS_FACEUP
	if re:GetHandler():IsCode(99970946) then isLuci=POS_FACEDOWN end
	
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)~=0 then
		local g1=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		local g2=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #g1>0 or #g2>0 then 
			Duel.BreakEffect()
			Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
			Duel.Remove(g2,isLuci,REASON_EFFECT)
			Duel.Draw(tp,#g1,REASON_EFFECT)
			Duel.Draw(1-tp,#g2,REASON_EFFECT)
		end
	end
end

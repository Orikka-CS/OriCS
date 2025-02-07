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
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:Select(tp,1,2,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)
	end
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsSetCard(0x3d70) and rp==tp and re:IsMonsterEffect() and re:GetHandler()~=e:GetHandler()
		and re:GetActivateLocation()&LSTN("HMG")>0
end
function s.tar3fil(c)
	return c:IsSetCard(0x3d70) and c:IsAbleToRemove()
end
function s.tar3fil2(c)
	return c:IsSetCard(0x3d70) and c:IsAbleToHand()
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.tar3fil,tp,LOCATION_GRAVE,0,nil)
	local g1=Duel.GetMatchingGroup(s.tar3fil2,tp,LOCATION_GRAVE,0,nil)
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	if re:GetHandler():IsCode(99970946) then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,1,1-tp,LOCATION_GRAVE)
	else
		g:Merge(g2)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,PLAYER_ALL,LOCATION_GRAVE)
	end
end
function s.check(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetControler)==#sg
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local isLuci=POS_FACEUP
	if re:GetHandler():IsCode(99970946) then isLuci=POS_FACEDOWN end
	
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)~=0 then
		local g=Duel.GetMatchingGroup(s.tar3fil,tp,LOCATION_GRAVE,0,nil)
		local g1=Duel.GetMatchingGroup(s.tar3fil2,tp,LOCATION_GRAVE,0,nil)
		local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
		if #g2>0 then
			if isLuci then
				if #g>0 then
					Duel.BreakEffect()
					g=g:Select(tp,1,1,nil)
					g2=g2:Select(tp,1,1,nil)
					Duel.SendtoHand(g,tp,REASON_EFFECT)
					Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
				end
			else
				if #g1>0 then
					Duel.BreakEffect()
					g1=g1:Select(tp,1,1,nil)
					g2=g2:Select(tp,1,1,nil)
					Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
					Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
				end
			end
		end
	end
end

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
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCL(1,{id,1})
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)

end

function s.tar1fil(c)
	return c:IsSetCard(0x3d70) and c:IsAbleToHand() and c:IsMonster()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar1fil,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tar1fil,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsSetCard(0x3d70) and rp==tp and re:IsMonsterEffect() and re:GetHandler()~=e:GetHandler()
		and re:GetActivateLocation()&LSTN("HMG")>0
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetDecktopGroup(tp,2)
	local g2=Duel.GetDecktopGroup(1-tp,2)
	g:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,8,PLAYER_ALL,LOCATION_DECK)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local isLuci=POS_FACEUP
	if re:GetHandler():IsCode(99970946) then isLuci=POS_FACEDOWN end
	
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)~=0 then
		local g=Duel.GetDecktopGroup(tp,2)
		local g2=Duel.GetDecktopGroup(1-tp,2)
		Duel.BreakEffect()
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		Duel.Remove(g2,isLuci,REASON_EFFECT)
	end
end

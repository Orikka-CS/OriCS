--[ MHR ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=MakeEff(c,"I","HMG")
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCL(1,id)
	e1:SetCost(aux.bfgcost)
	e1:SetCondition(function(e) return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),99970947) end)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(function(e) return Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),99970947) end)
	c:RegisterEffect(e2)
	
	local e3=MakeEff(c,"Qf","R")
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCL(1,{id,1})
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)

end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3d70))
	e1:SetValue(aux.tgoval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,0,1,aux.Stringid(id,0),nil)
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsSetCard(0x3d70) and rp==tp and re:IsMonsterEffect() and re:GetHandler()~=e:GetHandler()
		and re:GetActivateLocation()&LSTN("HMG")>0
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	if re:GetHandler():IsCode(99970946) then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
	else
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
	end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local isLuci=re:GetHandler():IsCode(99970946)
	
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.BreakEffect()
		if isLuci then
			Duel.Damage(1-tp,2000,REASON_EFFECT,true)
		else
			Duel.Damage(tp,1000,REASON_EFFECT,true)
			Duel.Damage(1-tp,1000,REASON_EFFECT,true)
		end
		Duel.RDComplete()
	end
end

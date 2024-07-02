--초록 실루엣과 꼭두각시 인형
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.afil1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
end
function s.afil1(c)
	return c:IsAttribute(ATTRIBUTE_WIND)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_PZONE,0,1,c,ATTRIBUTE_WIND)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(s.ctar11)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end
function s.ctar11(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
function s.tfil1(c,e,tp,lsc,rsc,ft)
	local lv=c:GetLevel()
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_WIND)
		and c:HasLevel() and lv>lsc and lv<rsc
		and ((ft>1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)) or c:IsAbleToHand())
		and not c:IsCode(id)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local c=e:GetHandler()
	local lc=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local rc=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not (lc and rc) then
		return false
	end
	local lsc=lc:GetLeftScale()
	local rsc=rc:GetRightScale()
	if lsc>rsc then
		lsc,rsc=rsc,lsc
	end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		ft=1
	end
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil1,tp,LOCATION_DECK,0,1,nil,e,tp,lsc,rsc,ft)
			and ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:HasLevel()
			and c:GetLevel()>lsc and c:GetLevel()<rsc
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lc=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local rc=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not (lc and rc) then
		return
	end
	local lsc=lc:GetLeftScale()
	local rsc=rc:GetRightScale()
	if lsc>rsc then
		lsc,rsc=rsc,lsc
	end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		ft=1
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tfil1,tp,LOCATION_DECK,0,1,1,nil,e,tp,lsc,rsc,ft)
	local tc=g:GetFirst()
	if tc then
		if ft<=1 or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) or Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end
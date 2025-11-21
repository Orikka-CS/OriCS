--[ Heishou Pack ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_HANDES+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	
end

function s.tar1f(c)
	return c:IsSetCard(0xad71) and c:IsMonster() and c:IsAbleToHand()
end
function s.op1f(c,e,tp)
	return c:IsSetCard(0xad71) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar1f,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,99971041),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsBattlePhase() and Duel.IsExistingMatchingCard(s.op1f,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
	end		
	if Duel.GetAttacker() and Duel.GetAttacker():IsCode(99971041) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tar1f,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		Duel.ConfirmCards(1-tp,g)
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,99971041),tp,LOCATION_ONFIELD,0,1,nil)
			and Duel.IsBattlePhase() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tc=Duel.SelectMatchingCard(tp,s.op1f,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
			if tc then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
				local honglu=Duel.GetFirstMatchingCard(aux.FaceupFilter(Card.IsCode,99971041),tp,LOCATION_ONFIELD,0,nil)
				local heishou=0
				if tc:IsCode(99971042,99971043,99971044) then heishou=2
					elseif tc:IsCode(99971045,99971046) then heishou=3
					elseif tc:IsCode(99971047,99971055) then heishou=4
					elseif tc:IsCode(99971048) then heishou=5
					elseif tc:IsCode(99971056) then heishou=6
				end
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(aux.Stringid(id,heishou))
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetReset(RESETS_STANDARD_PHASE_END)
				honglu:RegisterEffect(e1)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetDescription(aux.Stringid(id,1))
				e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetReset(RESETS_STANDARD_PHASE_END)
				tc:RegisterEffect(e2)
			end
		end
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end

function s.tar2f(c)
	return c:IsDiscardable() and c:IsSetCard(0xad71) and c:IsMonster()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar2f,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT)
		and c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.DiscardHand(tp,s.tar2f,1,1,REASON_EFFECT|REASON_DISCARD)>0 and c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end

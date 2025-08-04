--스컬 오브 네크로워커
local s,id=GetID()
function s.initial_effect(c)
	--덱에서, 같은 이름의 카드가 자신 묘지에 존재하지 않는 "네크로워커" 몬스터 1장을 고르고, 패에 넣거나 특수 소환한다.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--이 메인 페이즈 중, 자신 필드의 "네크로워커" 카드는 상대가 발동한 효과를 받지 않는다.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.immcon)
	e2:SetCost(s.immcost)
	e2:SetOperation(s.immop)
	c:RegisterEffect(e2)
end
s.listed_series={0xc24}
function s.filter(c,ft,e,tp)
	return c:IsSetCard(0xc24) and c:IsMonster() and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
		and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,ft,e,tp)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,ft,e,tp)
	if #g>0 then
		local th=g:GetFirst():IsAbleToHand()
		local sp=ft>0 and g:GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false)
		local op=0
		if th and sp then op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
		elseif th then op=0
		else op=1 end
		if op==0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		else
			local tc=g:GetFirst()
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			--Cannot attack
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3206)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
		end
	end
end
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.cfilter(c)
	return c:IsSetCard(0xc24) and c:IsAbleToRemoveAsCost()
end
function s.immcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() and Duel.GetFlagEffect(tp,id)==0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,0,120,c)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xc24))
	e1:SetValue(s.efilter)
	if Duel.IsPhase(PHASE_MAIN1) then
		e1:SetReset(RESET_PHASE|PHASE_MAIN1)
	else
		e1:SetReset(RESET_PHASE|PHASE_MAIN2)
	end
	if Duel.IsPhase(PHASE_MAIN1) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_MAIN1,0,1)
	else
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_MAIN2,0,1)
	end
	Duel.RegisterEffect(e1,tp)
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
--나바슈파타 아스트라
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c)
	return c:IsSetCard(0xf3d) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.op1cfilter(c)
	return c:IsFaceup() and c:IsOriginalType(TYPE_SYNCHRO)
end

function s.op1exfilter(c)
	return c:IsSetCard(0xf3d) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToGrave()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		local ct=Duel.GetMatchingGroupCount(s.op1cfilter,tp,LOCATION_ONFIELD,0,nil)
		local exg=Duel.GetMatchingGroup(s.op1exfilter,tp,LOCATION_EXTRA,0,nil)
		local opp_ex=Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)
		if ct>0 and #exg>0 and opp_ex>=ct and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local exsg=aux.SelectUnselectGroup(exg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
			if Duel.SendtoGrave(exsg,REASON_EFFECT)>0 and exsg:GetFirst():IsLocation(LOCATION_GRAVE) then
				local rg=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
				local rsg=rg:RandomSelect(tp,ct)
				Duel.SendtoGrave(rsg,REASON_EFFECT)
			end
		end
	end
end

--effect 2
function s.tg2filter(c,e)
	return c:IsType(TYPE_SYNCHRO) and not c:IsForbidden() and c:IsCanBeEffectTarget(e)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOFIELD)
	Duel.SetTargetCard(sg)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.MoveToField(tg,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		tg:RegisterEffect(e1)
	end
end
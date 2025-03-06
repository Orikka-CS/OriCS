--나우프라테 에듀케이터 세뇨라
local s,id=GetID()
function s.initial_effect(c)
	--link
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,3,s.linkfilter)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--link
function s.linkfilter(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0xf28,lc,sumtype,tp)
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler()
end

function s.tg1gfilter(c)
	return c:IsSetCard(0xf28) and c:IsAbleToGrave()
end

function s.tg1filter(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)   
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.tg1filter(chkc,e) end
	local gg=Duel.GetMatchingGroup(s.tg1gfilter,tp,LOCATION_DECK,0,nil)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),e)
	if chk==0 then return #gg>0 and #g>0 and e:GetHandler():GetLinkedGroupCount()>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,math.min(e:GetHandler():GetLinkedGroupCount(),#gg),aux.TRUE,1,tp,HINTMSG_RTOHAND)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,gg,#sg,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,#sg,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	local gg=Duel.GetMatchingGroup(s.tg1gfilter,tp,LOCATION_DECK,0,nil)
	if #tg>0 and #gg>=#tg then
		local gsg=aux.SelectUnselectGroup(gg,e,tp,#tg,#tg,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
		if Duel.SendtoGrave(gsg,REASON_EFFECT)>0 then
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
		end
	end
end

--effect 2
function s.tg2filter(c,e)
	return c:IsSetCard(0xf28) and c:IsSpellTrap() and c:IsCanBeEffectTarget(e) and c:IsAbleToHand() and c:IsFaceup()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,tp,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetFirstTarget()
	if tg:IsRelateToEffect(e) then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
		local dg=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,nil)
		local dsg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DISCARD)
		Duel.SendtoGrave(dsg,REASON_EFFECT+REASON_DISCARD)
	end
end
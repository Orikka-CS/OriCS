--노스탤지어 아카이브
local m=99000219
local cm=_G["c"..m]
function cm.initial_effect(c)
	aux.AddCodeList(c,99000218)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
cm.card_code_list={99000218}
function cm.filter(c,e,tp)
	return aux.IsCodeListed(c,99000218) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cm.drfilter(c)
	return aux.IsCodeListed(c,99000218) and c:IsAbleToDeck()
end
function cm.ctfilter(c)
	return c:IsFaceup() and c:IsCode(99000218)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=1
	if Duel.IsExistingMatchingCard(cm.ctfilter,tp,LOCATION_MZONE,0,1,nil) then ct=2 end
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cm.drfilter(chkc) end
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
			and Duel.GetFlagEffect(tp,m)==0
	local b2=Duel.IsPlayerCanDraw(tp,ct) and Duel.IsExistingTarget(cm.drfilter,tp,LOCATION_GRAVE,0,3,nil)
			and Duel.GetFlagEffect(tp,m+100)==0
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(m,0),aux.Stringid(m,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(m,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(m,1))+1
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectTarget(tp,cm.drfilter,tp,LOCATION_GRAVE,0,3,3,nil)
		e:SetLabel(ct)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			tc:CompleteProcedure()
		end
		Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
	else
		local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)==0 then return end
		Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
		local g=Duel.GetOperatedGroup()
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		if ct>0 then
			Duel.BreakEffect()
			Duel.Draw(tp,e:GetLabel(),REASON_EFFECT)
		end
		Duel.RegisterFlagEffect(tp,m+100,RESET_PHASE+PHASE_END,0,1)
	end
end
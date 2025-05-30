--왕립 속기도서관
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","G")
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetCL(1,id)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:SetLabel(0)
		return true
	end
	if Duel.IsCanRemoveCounter(tp,1,0,COUNTER_SPELL,3,REASON_COST)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		e:SetLabel(1)
		Duel.RemoveCounter(tp,1,0,COUNTER_SPELL,3,REASON_COST)
	else
		e:SetLabel(0)
	end
end
function s.tfil1(c)
	return c:IsSetCard("도서관") and c:IsAbleToHand() and not c:IsCode(id)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:SetLabel(0)
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
	if e:GetLabel()==1 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
		Duel.SPOI(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	if e:GetLabel()==1 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(Card.IsAbleToDeckAsCost,tp,"H",0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SMCard(tp,Card.IsAbleToDeckAsCost,tp,"H",0,1,1,nil)
	if Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))==0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)
	else
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
	end
end
function s.tfil2(c)
	if not (c:IsFaceup() and c:IsCanAddCounter(COUNTER_SPELL,1)) then
		return false
	end
	local eff=c:GetCardEffect(EFFECT_COUNTER_LIMIT|COUNTER_SPELL)
	return eff and eff:GetValue()==3 and c:IsCanAddCounter(COUNTER_SPELL,3-c:GetCounter(COUNTER_SPELL))
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsControler(tp) and chkc:IsOnField() and s.tfil2(chkc)
	end
	if chk==0 then
		return c:IsAbleToDeck() and Duel.IETarget(s.tfil2,tp,"O",0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.STarget(tp,s.tfil2,tp,"O",0,1,1,nil)
	Duel.SOI(0,CATEGORY_TODECK,c,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup()
		and tc:AddCounter(COUNTER_SPELL,3-tc:GetCounter(COUNTER_SPELL))
		and c:IsRelateToEffect(e) and c:IsAbleToDeck() then
		Duel.BreakEffect()
		if Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))==0 then
			Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
		else
			Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
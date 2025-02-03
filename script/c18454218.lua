--고스텔라 이들레
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"F","H")
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.con1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","M")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetD(id,0)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"I","M")
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetD(id,1)
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
end
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.GetLocCount(tp,"M")>0 and Duel.GetFieldGroupCount(tp,LSTN("M"),0)==0
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ghost=Duel.GetPlayerEffect(tp,EFFECT_GHOSTELLAR)
	if chk==0 then
		return ghost or c:IsReleasable()
	end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	if ghost then
		Duel.Hint(HINT_CARD,0,ghost:GetHandler():GetCode())
		ghost:Reset()
		e:SetLabel(0)
	else
		Duel.Release(c,REASON_COST)
		e:SetLabel(1)
	end
end
function s.tfil2(c)
	return c:IsSetCard("고스텔라") and c:IsAbleToHand() and c:IsType(TYPE_EQUIP)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil2,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil2,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	if e:GetLabel()~=0 then
		local e1=MakeEff(c,"F")
		e1:SetCode(EFFECT_GHOSTELLAR)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTR(1,0)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToDeck() and Duel.IEMCard(Card.IsAbleToDeck,tp,"HO",0,1,c) and Duel.IsPlayerCanDraw(tp)
	end
	Duel.SOI(0,CATEGORY_TODECK,c,1,tp,"HO")
	Duel.SOI(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SMCard(tp,Card.IsAbleToDeck,tp,"HO",0,1,1,c)
		if #g>0 then
			g:AddCard(c)
			Duel.HintSelection(g)
			if Duel.SendtoDeck(g,nil,0,REASON_EFFECT)>0 then
				Duel.ShuffleDeck(tp)
				Duel.BreakEffect()
				Duel.Draw(tp,2,REASON_EFFECT)
			end
		end
	end
end
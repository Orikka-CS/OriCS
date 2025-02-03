--혜성(슈팅 고스텔라)-천상의 소프라노
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")	
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
end
function s.cfil1(c)
	return c:IsSetCard("고스텔라") and c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ghost=Duel.GetPlayerEffect(tp,EFFECT_GHOSTELLAR)
	if chk==0 then
		return not ghost or Duel.IEMCard(s.cfil1,tp,"D",0,1,nil)
	end
	if ghost then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SMCard(tp,s.cfil1,tp,"D",0,1,1,nil)
		Duel.SendtoGrave(g,REASON_COST)
		e:SetLabel(0)
	else
		e:SetLabel(1)
	end
end
function s.tfil1(c)
	return c:IsSetCard("고스텔라") and c:IsAbleToHand()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil)
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
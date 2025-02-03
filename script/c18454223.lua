--혼성(카오스 고스텔라)-황천의 디스토션
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(10000)
	return true
end
function s.tfil11(c)
	return c:IsSetCard("고스텔라") and c:IsAbleToGrave() and not c:IsCode(id)
end
function s.tfil12(c,e)
	return c:IsSetCard("고스텔라") and c:IsAbleToHand() and not c:IsCode(id) and c:IsCanBeEffectTarget(e)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return false
	end
	local ghost=Duel.GetPlayerEffect(tp,EFFECT_GHOSTELLAR)
	local label=e:GetLabel()
	local g1=Duel.GMGroup(s.tfil11,tp,"D",0,nil)
	local g2=Duel.GMGroup(s.tfil12,tp,"G",0,nil,e)
	local b1=(label~=10000 or ghost or Duel.CheckLPCost(tp,2000)) and g1:CheckSubGroup(aux.dncheck,2,2)
	local b2=(label~=10000 or ghost or Duel.IEMCard(Card.IsDiscardable,tp,"H",0,2,nil)) and g2:CheckSubGroup(aux.dncheck,2,2)
	if chk==0 then
		e:SetLabel(0)
		return b1 or b2
	end
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	if label==10000 then
		if op==1 then
			if ghost then
				Duel.Hint(HINT_CARD,0,ghost:GetHandler():GetCode())
				ghost:Reset()
			else
				Duel.PayLPCost(tp,2000)
				e:SetLabel(op|0x10000)
			end
		elseif op==2 then
			if ghost then
				Duel.Hint(HINT_CARD,0,ghost:GetHandler():GetCode())
				ghost:Reset()
			else
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
				local g=Duel.SMCard(tp,Card.IsDiscardable,tp,"H",0,2,2,nil)
				Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
				e:SetLabel(op|0x10000)
			end
		end
	end
	if op==1 then
		e:SetProperty(0)
		e:SetCategory(CATEGORY_TOGRAVE)
		Duel.SOI(0,CATEGORY_TOGRAVE,nil,2,tp,"D")
	elseif op==2 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetCategory(CATEGORY_TOHAND)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=g2:SelectSubGroup(tp,aux.dncheck,false,2,2)
		Duel.SetTargetCard(tg)
		Duel.SOI(0,CATEGORY_TOHAND,tg,2,0,0)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op&0xffff==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.GMGroup(s.tfil11,tp,"D",0,nil)
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		if sg and #sg==2 then
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	elseif op&0xffff==2 then
		local g=Duel.GetTargetCards(e)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
	if op&0x10000~=0 then
		local e1=MakeEff(c,"F")
		e1:SetCode(EFFECT_GHOSTELLAR)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTR(1,0)
		Duel.RegisterEffect(e1,tp)
	end
end
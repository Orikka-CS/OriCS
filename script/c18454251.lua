--功力狼 脚风倡拳
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
end
function s.cfil11(c,tp)
	return c:IsSetCard("功力") and not c:IsCode(id) and (c:IsAbleToGraveAsCost() or c:IsAbleToRemoveAsCost())
		and not Duel.IEMCard(s.cfil12,tp,"OGR",0,1,nil,c:GetCode())
end
function s.cfil12(c,code)
	return c:IsCode(code) and c:IsFaceup()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.cfil11,tp,"D",0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.cfil11,tp,"D",0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc:IsAbleToGraveAsCost() and (not tc:IsAbleToRemoveAsCost() or Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
		Duel.SendtoGrave(tc,REASON_COST)
	else
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
	end
end
function s.tfil1(c,tp)
	return c:IsSetCard("功力") and not c:IsCode(id)
		and not Duel.IEMCard(s.cfil12,tp,"OGR",0,1,nil,c:GetCode())
		and ((c:IsAbleToHand() and Duel.GetFlagEffect(tp,id-10000)==0)
			or (c:IsAbleToGrave() and Duel.GetFlagEffect(tp,id-20000)==0)
			or (c:IsAbleToRemove() and Duel.GetFlagEffect(tp,id-30000)==0))
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil,tp)
	end
	Duel.SPOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
	Duel.SPOI(0,CATEGORY_TOGRAVE,nil,1,tp,"D")
	Duel.SPOI(0,CATEGORY_REMOVE,nil,1,tp,"D")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil,tp)
	local tc=g:GetFirst()
	local b1=tc:IsAbleToHand() and Duel.GetFlagEffect(tp,id-10000)==0
	local b2=tc:IsAbleToGrave() and Duel.GetFlagEffect(tp,id-20000)==0
	local b3=tc:IsAbleToRemove() and Duel.GetFlagEffect(tp,id-30000)==0
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)},{b3,aux.Stringid(id,3)})
	if op==1 then
		Duel.RegisterFlagEffect(tp,id-10000,RESET_PHASE+PHASE_END,0,1)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	elseif op==2 then
		Duel.RegisterFlagEffect(tp,id-20000,RESET_PHASE+PHASE_END,0,1)
		Duel.SendtoGrave(g,REASON_EFFECT)
	elseif op==3 then
		Duel.RegisterFlagEffect(tp,id-30000,RESET_PHASE+PHASE_END,0,1)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
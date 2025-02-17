--µµÆÄ¹Î ÁõÆøÁ¦
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","F")
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetTR("M",0)
	e2:SetTarget(s.tar2)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_DEFENSE)
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"I","F")
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetCL(1)
	WriteEff(e4,4,"TO")
	c:RegisterEffect(e4)
end
function s.ofil1(c)
	return c:IsSetCard("µµÆÄ¹Î") and c:IsAbleToGrave() and not c:IsCode(id)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.ofil1,tp,"D",0,0,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function s.tfil2(c,code)
	return c:IsCode(code) and c:IsFaceup()
end
function s.tar2(e,c)
	local tp=e:GetHandlerPlayer()
	return c:IsSetCard("µµÆÄ¹Î") and Duel.IEMCard(s.tfil2,tp,"O",0,1,c,c:GetCode())
end
function s.val2(e,c)
	return c:GetBaseAttack()*2
end
function s.val3(e,c)
	return c:GetBaseDefense()*2
end
function s.tfil4(c,e)
	return c:IsSetCard("µµÆÄ¹Î") and c:IsAbleToHand() and not c:IsCode(id) and c:IsCanBeEffectTarget(e)
end
function s.tfun4(g,ct)
	return g:GetClassCount(Card.GetCode)==1 and (ct>1 or #g==2)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return false
	end
	local g1=Duel.GMGroup(s.tfil4,tp,"G",0,nil,e)
	local g2=Duel.GMGroup(Card.IsAbleToGrave,tp,"H",0,nil)
	if chk==0 then
		return #g2>0 and g1:CheckSubGroup(s.tfun4,1,2,#g2)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=g1:SelectSubGroup(tp,s.tfun4,false,1,2,#g2)
	e:SetLabel(#g)
	Duel.SetTargetCard(g)
	Duel.SOI(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetTargetCards(e)
	local g2=Duel.GMGroup(Card.IsAbleToGrave,tp,"H",0,nil)
	local minct=2
	if e:GetLabel()==2 then
		minct=1
	end
	if #g2>=minct then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg2=g2:Select(tp,minct,2,nil)
		if Duel.SendtoGrave(sg2,REASON_EFFECT)>0 and #g1>0 then
			Duel.SendtoHand(g1,nil,REASON_EFFECT)
		end
	end
end
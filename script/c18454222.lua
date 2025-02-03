--서성(스크롤 고스텔라)-지식의 라퓨타
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")	
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","F")
	e2:SetCL(1)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ghost=Duel.GetPlayerEffect(tp,EFFECT_GHOSTELLAR)
	if chk==0 then
		return ghost or Duel.CheckLPCost(tp,1000)
	end
	if ghost then
		Duel.Hint(HINT_CARD,0,ghost:GetHandler():GetCode())
		ghost:Reset()
		e:SetLabel(0)
	else
		Duel.PayLPCost(tp,1000)
		e:SetLabel(1)
	end
end
function s.tfil1(c)
	return c:IsSetCard("고스텔라") and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
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
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local ghost=Duel.GetPlayerEffect(tp,EFFECT_GHOSTELLAR)
	if chk==0 then
		return ghost or Duel.IEMCard(Card.IsDiscardable,tp,"H",0,1,nil)
	end
	if ghost then
		Duel.Hint(HINT_CARD,0,ghost:GetHandler():GetCode())
		ghost:Reset()
		e:SetLabel(0)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local g=Duel.SMCard(tp,Card.IsDiscardable,tp,"H",0,1,1,nil)
		Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
		e:SetLabel(1)
	end
end
function s.tfil2(c,tp)
	local te=c:CheckActivateEffect(false,false,false)
	local ft=Duel.GetLocCount(tp,"S")
	return te and c:IsCode(18454226) and (ft>0 or c:IsType(TYPE_FIELD)) and te:IsActivatable(tp)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil2,tp,"D",0,1,nil,tp)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RESOLVECARD)
	local tg=Duel.SMCard(tp,s.tfil2,tp,"D",0,1,1,nil,tp)
	local tc=tg:GetFirst()
	if tc then
		local tpe=tc:GetType()
		local te=tc:GetActivateEffect()
		local co=te:GetCost()
		local tg=te:GetTarget()
		local op=te:GetOperation()
		e:SetCategory(te:GetCategory())
		e:SetProperty(te:GetProperty())
		if bit.band(tpe,TYPE_FIELD)>0 then
			Duel.MoveToField(tc,tp,tp,LSTN("F"),POS_FACEUP,true)
		else
			Duel.MoveToField(tc,tp,tp,LSTN("S"),POS_FACEUP,true)
		end
		Duel.HintActivation(te)
		e:SetActiveEffect(te)
		te:UseCountLimit(tp,1,true)
		if tpe&(TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
			tc:CancelToGrave(false)
		end
		tc:CreateEffectRelation(te)
		if co then
			co(te,tp,eg,ep,ev,re,r,rp,1)
		end
		if tg then
			tg(te,tp,eg,ep,ev,re,r,rp,1)
		end
		Duel.BreakEffect()
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local etc=nil
		if g then
			etc=g:GetFirst()
			while etc do
				etc:CreateEffectRelation(te)
				etc=g:GetNext()
			end
		end
		if op and not tc:IsDisabled() then
			op(te,tp,eg,ep,ev,re,r,rp)
		end
		tc:ReleaseEffectRelation(te)
		if g then
			etc=g:GetFirst()
			while etc do
				etc:ReleaseEffectRelation(te)
				etc=g:GetNext()
			end
		end
		e:SetActiveEffect(nil)
		e:SetCategory(0)
		e:SetProperty(0)
		Duel.RaiseEvent(tc,18452923,te,0,tp,tp,Duel.GetCurrentChain())
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
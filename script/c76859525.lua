--모노크로니클 히라비나
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"Qo","H")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCountLimit(1,id)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FC","M")
	e2:SetCode(EVENT_CHAIN_SOLVING)
	WriteEff(e2,2,"O")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"I","M")
	e3:SetCL(1,{id,1})
	WriteEff(e3,3,"CO")
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCondition(s.con4)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"F","M")
	e5:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e5:SetD(id,1)
	e5:SetTR("HM",0)
	e5:SetCondition(s.con5)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2c6))
	c:RegisterEffect(e5)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsDiscardable()
	end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.tfil1(c)
	return c:IsSetCard(0x2c6) and c:IsType(TYPE_FIELD) and (c:IsFaceup() or not c:IsLoc("R"))
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"DGR",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,0,tp,"DGR")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,aux.NecroValleyFilter(s.tfil1),tp,"DGR",0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		if tc:IsAbleToHand() and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		else
			local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
			if fc then
				Duel.SendtoGrave(fc,REASON_RULE)
				Duel.BreakEffect()
			end
			Duel.MoveToField(tc,tp,tp,LSTN("F"),POS_FACEUP,true)
		end
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetDefense()<800 then
		return
	end
	if c:IsImmuneToEffect(re) then
		return
	end
	if rp==tp then
		return
	end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		return
	end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or #g<1 then
		return
	end
	if g:IsContains(c) then
		c:ReleaseEffectRelation(re)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetReset(RESET_EVENT+0x1ff0000)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(-800)
		c:RegisterEffect(e1)
	end
end
function s.cfil3(c)
	return c:IsSetCard(0x2c6) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and not c:IsCode(id)
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.cfil3,tp,"D",0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.cfil3,tp,"D",0,1,1,nil)
	local tc=g:GetFirst()
	e:SetLabelObject({tc:GetOriginalCodeRule(),tc:GetBaseAttack()})
	Duel.SendtoGrave(g,REASON_COST)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local code,atk=table.unpack(e:GetLabelObject())
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetValue(code)
		c:RegisterEffect(e1)
		local e2=MakeEff(c,"S")
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		e2:SetValue(atk)
		c:RegisterEffect(e2)
		c:CopyEffect(code,RESETS_STANDARD_PHASE_END,1)
	end
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()~=tp and ph>PHASE_MAIN1 and ph<PHASE_MAIN2
end
function s.nfil5(c)
	return c:IsFaceup() and c:IsSetCard(0x2c6)
end
function s.con5(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IEMCard(s.nfil5,tp,"F",0,1,nil)
end
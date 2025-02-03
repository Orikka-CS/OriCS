--은하린 신화적 데뷔
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FTo","S")
	e2:SetCode(18454238)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"STo")
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCL(1,{id,2})
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)
end
function s.ofil1(c)
	return c:IsSetCard("은하린") and c:IsAbleToGrave() and not c:IsCode(id)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.ofil1,tp,"D",0,0,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp
end
function s.tfil2(c)
	return c:IsSetCard("은하린") and c:IsAbleToDeck() and not c:IsCode(id)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("G") and chkc:IsControler(tp) and s.tfil2(chkc)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil2,tp,"G",0,1,nil) and Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.STarget(tp,s.tfil2,tp,"G",0,1,3,nil)
	Duel.SOI(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SOI(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 and Duel.SendtoDeck(g,nil,0,REASON_EFFECT)>0 then
		Duel.ShuffleDeck(tp)
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
end
function s.tfil31(c)
	return c:IsSetCard("은하린") and c:IsFaceup() and (not c:IsAttribute(ATTRIBUTE_WATER) or not c:IsRace(RACE_CYBERSE))
end
function s.tfil32(c)
	return c:IsSetCard("은하린") and c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		if e:GetLabel()==1 then
			return chkc:IsLoc("M") and chkc:IsControler(tp) and s.tfil31(chkc)
		elseif e:GetLabel()==2 then
			return chkc:IsLoc("M") and chkc:IsControler(tp) and s.tfil32(chkc)
		end
		return false
	end
	local b1=Duel.IETarget(s.tfil31,tp,"M",0,1,nil)
	local b2=Duel.IETarget(s.tfil32,tp,"M",0,1,nil)
	if chk==0 then
		return b1 or b2
	end
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,0)
		Duel.STarget(tp,s.tfil31,tp,"M",0,1,1,nil)
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,0)
		Duel.STarget(tp,s.tfil32,tp,"M",0,1,1,nil)
		if c:IsLoc("G") then
			Duel.SOI(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
		end
	end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local op=e:GetLabel()
	if op==1 then
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local e1=MakeEff(c,"S")
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(ATTRIBUTE_WATER)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CHANGE_RACE)
			e2:SetValue(RACE_CYBERSE)
			tc:RegisterEffect(e2)
		end
	elseif op==2 then
		if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_XYZ) then
			Duel.Overlay(tc,c)
		end
	end
end
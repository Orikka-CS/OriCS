--창성(스피어 고스텔라)-영원의 오르골
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e3=MakeEff(c,"STo")
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_TOGRAVE)
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(10000)
	return true
end
function s.tfil1(c,e,tp)
	return c:IsSetCard("고스텔라") and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		local op=e:GetLabel()
		if op&0xffff==1 then
			return chkc:IsControler(tp) and s.tfil1(chkc) and c:IsLoc("R")
		elseif op&0xffff==2 then
			return chkc:IsControler(tp) and s.tfil1(chkc) and c:IsLoc("G")
		end
		return false
	end
	local ghost=Duel.GetPlayerEffect(tp,EFFECT_GHOSTELLAR)
	local label=e:GetLabel()
	local b1=(label~=10000 or ghost or Duel.IEMCard(Card.IsDiscardable,tp,"H",0,1,nil))
		and Duel.GetLocCount(tp,"M")>0 and Duel.IETarget(s.tfil1,tp,"R",0,1,nil,e,tp)
	local b2=(label~=10000 or ghost or Duel.CheckLPCost(tp,1000))
		and Duel.GetLocCount(tp,"M")>0 and Duel.IETarget(s.tfil1,tp,"G",0,1,nil,e,tp)
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
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
				local g=Duel.SMCard(tp,Card.IsDiscardable,tp,"H",0,1,1,nil)
				Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
				e:SetLabel(op|0x10000)
			end
		elseif op==2 then
			if ghost then
				Duel.Hint(HINT_CARD,0,ghost:GetHandler():GetCode())
				ghost:Reset()
			else
				Duel.PayLPCost(tp,1000)
				e:SetLabel(op|0x10000)
			end
		end
	end
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.STarget(tp,s.tfil1,tp,"R",0,1,1,nil,e,tp)
		Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.STarget(tp,s.tfil1,tp,"G",0,1,1,nil,e,tp)
		Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op&0xffff==1 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			Duel.Equip(tp,c,tc)
			local e1=MakeEff(c,"S")
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.oval11)
			e1:SetLabelObject(tc)
			c:RegisterEffect(e1)
		end
	elseif op&0xffff==2 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			Duel.Equip(tp,c,tc)
			local e1=MakeEff(c,"S")
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.oval11)
			e1:SetLabelObject(tc)
			c:RegisterEffect(e1)
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
function s.oval11(e,c)
	return e:GetLabelObject()==c
end
function s.tfil3(c)
	return c:IsSetCard("고스텔라") and c:IsAbleToGrave() and c:IsType(TYPE_MONSTER)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil3,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOGRAVE,nil,1,tp,"D")
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.tfil3,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
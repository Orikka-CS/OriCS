--라이트☆멜론★글로리아
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"Qo","M")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DISABLE)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","H")
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	WriteEff(e2,2,"NCTO")
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		s[0]=0
		s[1]=0
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	s[0]=0
	s[1]=0
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToHandAsCost()
	end
	Duel.SendtoHand(c,nil,REASON_EFFECT)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsOnField() and chkc:IsNegatable()
	end
	if chk==0 then
		return Duel.IETarget(Card.IsNegatable,tp,"O","O",1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.STarget(tp,Card.IsNegatable,tp,"O","O",1,1,nil)
	Duel.SOI(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) and tc:IsRelateToEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=MakeEff(c,"S")
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=MakeEff(c,"S")
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
	local e4=MakeEff(c,"F")
	e4:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTR(1,0)
	e4:SetValue(2)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)
	local e5=MakeEff(c,"F")
	e5:SetCode(EFFECT_CANNOT_SUMMON)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTR(1,0)
	e5:SetTarget(s.otar15)
	e5:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e5,tp)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e6,tp)
end
function s.otar15(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.nfil2(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsFaceup()
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IEMCard(s.nfil2,tp,"M","M",1,nil)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemoveAsCost()
	end
	local fid=c:GetFieldID()
	if Duel.Remove(c,POS_FACEUP,REASON_COST+REASON_TEMPORARY)~=0 then
		c:RegisterFlagEffect(id,RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD,0,1,fid)
		local e1=MakeEff(c,"FC")
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetLabel(fid)
		e1:SetCountLimit(1)
		e1:SetOperation(s.cop21)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.cop21(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local fid=e:GetLabel()
	if tc:GetFlagEffectLabel(id)==fid then
		Duel.HintSelection(Group.FromCards(tc))
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function s.tfil2(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and (c:GetType()&0x6)&s[tp]~=(c:GetType()&0x6)
		and c:IsSetCard("☆멜론★")
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil2,tp,"D",0,1,nil,tp)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil2,tp,"D",0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		s[tp]=s[tp]|(tc:GetType()&0x6)
		Duel.ConfirmCards(1-tp,tc)
	end
end
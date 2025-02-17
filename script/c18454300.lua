--À©µå¡Ù¸á·Ð¡Úºí·Î¼¶
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"Qo","M")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TOHAND)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","H")
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
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
		return chkc:IsOnField() and chkc:IsAbleToHand()
	end
	if chk==0 then
		return Duel.IETarget(Card.IsAbleToHand,tp,"O","O",1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.STarget(tp,Card.IsAbleToHand,tp,"O","O",1,1,nil)
	Duel.SOI(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.ofil1(c)
	return c:IsLevel(1) and c:IsRace(RACE_PLANT) and c:IsSummonable(true,nil)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTR(1,0)
	e1:SetTarget(s.otar11)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e2,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SMCard(tp,s.ofil1,tp,"HM",0,0,1,nil)
	local sc=g:GetFirst()
	if sc then
		Duel.Summon(tp,sc,true,nil)
	end
end
function s.otar11(e,c)
	return c:IsAttribute(ATTRIBUTE_WIND)
end
function s.nfil2(c)
	return c:IsRace(RACE_PLANT) and c:IsFaceup()
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
function s.tfil2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and (c:GetAttribute()&0x7f)&s[tp]~=(c:GetAttribute()&0x7f)
		and c:IsSetCard("¡Ù¸á·Ð¡Ú") and not c:IsAttribute(ATTRIBUTE_WIND)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0 and Duel.IEMCard(s.tfil2,tp,"D",0,1,nil,e,tp)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"D")
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocCount(tp,"M")<=0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SMCard(tp,s.tfil2,tp,"D",0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		s[tp]=s[tp]|(tc:GetAttribute()&0x7f)
	end
end
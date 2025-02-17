--¡Ù¸á·Ð¡ÚÅ×¸¶ÆÄÅ©
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SEARCH)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","F")
	WriteEff(e2,2,"CO")
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
function s.ofil1(c,tp)
	return c:IsSetCard("¡Ù¸á·Ð¡Ú") and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and (c:GetAttribute()&0x7f)&s[tp]~=(c:GetAttribute()&0x7f)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.ofil1,tp,"D",0,0,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		s[tp]=s[tp]|(tc:GetAttribute()&0x7f)
		Duel.ConfirmCards(1-tp,tc)
	end
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
		Duel.MoveToField(tc,tp,tp,LSTN("F"),POS_FACEUP,true)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_PLANT))
	e1:SetTR("M",0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	Duel.RegisterEffect(e2,tp)
	local e3=MakeEff(c,"F")
	e3:SetCode(EFFECT_CANNOT_INACTIVATE)
	e3:SetValue(s.oval23)
	Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_DISEFFECT)
	Duel.RegisterEffect(e4,tp)
end
function s.oval23(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	if not te then
		return false
	end
	local tc=te:GetHandler()
	return p==tp and tc:IsRace(RACE_PLANT)
end
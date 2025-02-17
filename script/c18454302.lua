--어스☆멜론★파밍
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"Qo","M")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOGRAVE)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","H")
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	WriteEff(e2,2,"CTO")
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
function s.tfil1(c)
	return c:IsLevel(1) and c:IsRace(RACE_PLANT) and c:IsAbleToGrave() and not c:IsCode(id)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOGRAVE,nil,1,tp,"D")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
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
		Duel.HintSelection(Group.FromCards(tc))
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function s.tfil21(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsFaceup()
end
function s.tfil22(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsLevel(1) and c:IsRace(RACE_PLANT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and (c:GetAttribute()&0x7f)&s[tp]~=(c:GetAttribute()&0x7f)
end
function s.tfun2(g)
	return g:GetClassCount(Card.GetAttribute)==#g
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return false
	end
	local g=Duel.GMGroup(s.tfil21,tp,"M","M",nil)
	local ct=#g
	local sg=Duel.GMGroup(s.tfil22,tp,"G",0,nil,e,tp)
	if chk==0 then
		return ct>0 and #sg>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=sg:SelectSubGroup(tp,s.tfun2,false,1,ct)
	Duel.SetTargetCard(tg)
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,tg,#tg,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e):Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
	local ft=Duel.GetLocCount(tp,"M")
	if ft>0 then
		if #g>ft then
			g=g:Select(tp,ft,ft,nil)
		end
		if #g>0 then
			local tc=g:GetFirst()
			while tc do
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
				s[tp]=s[tp]|(tc:GetAttribute()&0x7f)
				tc=g:GetNext()
			end
			Duel.SpecialSummonComplete()
		end
	end
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTR(1,0)
	e1:SetTarget(s.otar21)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e2,tp)
end
function s.otar21(e,c)
	return c:IsAttribute(ATTRIBUTE_EARTH)
end
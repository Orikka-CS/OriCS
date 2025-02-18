--¿öÅÍ¡Ù¸á·Ð¡ÚÆä½ºÆ¼¹ú
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"Qo","M")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","H")
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToHandAsCost()
	end
	Duel.SendtoHand(c,nil,REASON_EFFECT)
end
function s.tfil11(c,e,tp)
	return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeEffectTarget(e)
		and Duel.IEMCard(s.tfil12,tp,"D",0,1,nil,c:GetAttribute())
end
function s.tfil12(c,att)
	return c:IsSetCard("¡Ù¸á·Ð¡Ú") and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:IsAttribute(att)
end
function s.tfun1(g)
	return g:GetClassCount(Card.GetAttribute)==#g
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return false
	end
	local g=Duel.GMGroup(s.tfil11,tp,"M","M",c,e,tp)
	if chk==0 then
		return #g>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sg=g:SelectSubGroup(tp,s.tfun1,false,1,2)
	Duel.SetTargetCard(sg)
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	local tc=g:GetFirst()
	local sg=Group.CreateGroup()
	while tc do
		Duel.HintSelection(Group.FromCards(tc))
		local att=tc:GetAttribute()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=Duel.SMCard(tp,s.tfil12,tp,"D",0,1,1,nil,att)
		sg:Merge(tg)
		tc=g:GetNext()
	end
	if #sg>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,sg)
		if #g>0 then
			Duel.BreakEffect()
			tc=g:GetFirst()
			while tc do
				local e1=MakeEff(c,"S")
				e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
				e1:SetValue(ATTRIBUTE_WATER)
				tc:RegisterEffect(e1)
				tc=g:GetNext()
			end
		end
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
function s.tfil2(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GMGroup(s.tfil2,tp,"M","M",nil)
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0 and #g>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,18454306,0,TYPES_TOKEN,0,0,1,RACE_PLANT,ATTRIBUTE_WATER)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SOI(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GMGroup(s.tfil2,tp,"M","M",nil)
	local ct=#g
	if ct>0 and Duel.GetLocCount(tp,"M")>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,18454306,0,TYPES_TOKEN,0,0,1,RACE_PLANT,ATTRIBUTE_WATER) then
		for i=1,ct do
			local token=Duel.CreateToken(tp,18454306)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			if i==ct or not (Duel.GetLocCount(tp,"M")>0
				and Duel.IsPlayerCanSpecialSummonMonster(tp,18454306,0,TYPES_TOKEN,0,0,1,RACE_PLANT,ATTRIBUTE_WATER))
				or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				break
			end
		end
		Duel.SpecialSummonComplete()
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
	return c:IsAttribute(ATTRIBUTE_WATER)
end
--카툰니스트
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"SC")
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"S")
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetCondition(s.con3)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"STo")
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	WriteEff(e4,4,"TO")
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"STo")
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e5:SetCL(1,id)
	WriteEff(e5,5,"NTO")
	c:RegisterEffect(e5)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function s.nfil3(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
function s.con3(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IEMCard(s.nfil3,tp,0,"M",1,nil)
end
function s.tfil4(c)
	return c:IsType(TYPE_TOON) and c:IsAbleToHand()
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil4,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil4,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.con5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LSTN("O"))
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x1062,TYPE_MONSTER+TYPE_TOKEN+TYPE_TOON,
				1850,550,4,RACE_SPELLCASTER,ATTRIBUTE_WIND)
	end
	Duel.SOI(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocCount(tp,"M")>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x1062,TYPE_MONSTER+TYPE_TOKEN+TYPE_TOON,
			1850,550,4,RACE_SPELLCASTER,ATTRIBUTE_WIND) then
		local token=Duel.CreateToken(tp,id+1)
		local e1=MakeEff(c,"SC")
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		WriteEff(e1,1,"O")
		token:RegisterEffect(e1)
		local e2=MakeEff(c,"S")
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetCondition(s.con3)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e2)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		Duel.BreakEffect()
		Duel.SpecialSummonComplete()
	end
end
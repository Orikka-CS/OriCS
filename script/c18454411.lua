--색종이를 곱게 접어서
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH+EFFECT_COUNT_CODE_DUEL)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","F")
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTR("M","M")
	e2:SetTarget(s.tar2)
	e2:SetValue(500)
	c:RegisterEffect(e2)
end
function s.fil(c)
	return (c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_PYRO|RACE_BEAST|RACE_BEASTWARRIOR|RACE_DINOSAUR))
		or (c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_ROCK|RACE_WARRIOR|RACE_MACHINE|RACE_PLANT))
		or (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY|RACE_THUNDER|RACE_WYRM|RACE_CYBERSE))
		or (c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_WINGEDBEAST|RACE_INSECT|RACE_DRAGON|RACE_PSYCHIC))
		or (c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_AQUA|RACE_FISH|RACE_SEASERPENT|RACE_REPTILE))
		or (c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND|RACE_ZOMBIE|RACE_SPELLCASTER|RACE_ILLUSION))
end
function s.tfil1(c)
	return s.fil(c) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
function s.tar2(e,c)
	return s.fil(c)
end
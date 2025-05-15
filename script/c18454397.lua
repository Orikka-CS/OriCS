--성당
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","F")
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTR("M","M")
	e2:SetTarget(s.tar2)
	e2:SetValue(200)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetTarget(s.tar4)
	e4:SetValue(-200)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
end
function s.tar2(e,c)
	return not c:IsAttribute(ATTRIBUTE_DIVINE) and
		((not c:IsAttribute(ATTRIUBUTE_DARK) and c:IsRace(RACE_FAIRY))
			or (c:IsAttribute(ATTRIUBUTE_LIGHT) and c:IsRace(RACE_WARRIOR))
			or c:IsRace(RACE_DINASOUR|RACE_AQUA|RACE_THUNDER|RACE_CELESTIALWARRIOR|RACE_PYRO
				|RACE_SEASERPENT))
end
function s.tar4(e,c)
	return c:IsAttribute(ATTRIBUTE_DIVINE) or 
		(c:IsAttribute(ATTRIUBUTE_DARK) and c:IsRace(RACE_WARRIOR|RACE_FAIRY))
		or c:IsRace(RACE_DRAGON|RACE_MAGICALKNIGHT|RACE_SPELLCASTER|RACE_PSYCHIC|RACE_FIEND|RACE_ZOMBIE
			|RACE_OMEGAPSYCHIC|RACE_CREATORGOD|RACE_WYRM|RACE_ILLUSION|RACE_DIVINE)
end
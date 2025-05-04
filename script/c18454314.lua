--특수 소환은 셀프입니다
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","S")
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTR(1,1)
	e2:SetTarget(s.tar2)
	c:RegisterEffect(e2)
end
function s.tar2(e,c,sump,sumtype,sumpos,targetp,se)
	local sc=se:GetHandler()
	return se:IsHasType(EFFECT_TYPE_ACTIONS) and c:IsType(TYPE_MONSTER) and sc~=c
end
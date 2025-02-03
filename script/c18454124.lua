--초록 실시간 클락 인터럽트
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.pfil1,2,2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EFFECT_EXTRA_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(1,1)
	e1:SetOperation(s.op1)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
end
function s.pfil1(c,lc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_WIND,lc,sumtype,tp) and c:IsType(TYPE_PENDULUM,lc,sumtype,tp)
end
s.og1=nil
function s.op1(c,e,tp,sg,mg,lc,og,chk)
	if not s.og1 then
		return true
	end
	return true
end
function s.val1(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or sc~=e:GetHandler() then
			return Group.CreateGroup()
		else
			s.og1=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_PZONE,0,nil,0xc03)
			s.og1:KeepAlive()
			return s.og1
		end
	elseif chk==2 then
		if s.og1 then
			s.og1:DeleteGroup()
		end
		s.og1=nil
	end
end
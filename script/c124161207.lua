--클라랑슈의 소녀 알마
local s,id=GetID()
function s.initial_effect(c)
	--link
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.linkfilter,1,1)
end

--link
function s.linkfilter(c,scard,sumtype,tp)
	return c:IsSetCard(0xf2d,scard,sumtype,tp) and c:IsType(TYPE_EFFECT,scard,sumtype,tp)
end
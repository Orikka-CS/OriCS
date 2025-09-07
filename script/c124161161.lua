--휴프알로 룩 라마트쉬
local s,id=GetID()
function s.initial_effect(c)
	--xyz
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,6,2,s.ovfilter,aux.Stringid(id,0),2,s.ovop)
end

--xyz
function s.ovfilter(c,tp,lc)
	return c:IsFacedown() and c:IsCanBeXyzMaterial() and c:IsControler(tp) and c:IsLevel(6) and c:IsSetCard(0xf2a)
end

function s.ovop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end
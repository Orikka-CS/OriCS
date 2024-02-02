--클릭!
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	WriteEff(e1,1,"T")
	c:RegisterEffect(e1)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local exc=e:IsHasType(EFFECT_TYPE_ACTIVATE) and c or nil
	if chkc then
		return chkc:IsOnField() and chkc~=exc
	end
	if chk==0 then
		return Duel.IETarget(nil,tp,"O","O",1,exc)
	end
	Duel.STarget(tp,nil,tp,"O","O",1,1,exc)
end
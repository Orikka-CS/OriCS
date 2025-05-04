--넘쳐나는 온갖 재의 마녀
local s,id=GetID()
function s.initial_effect(c)
	if not s.global_check then
		s.global_check=true
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_STARTUP)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	aux.GlobalFullList()
end
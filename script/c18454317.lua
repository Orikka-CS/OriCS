--기다림의 기쁨
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	WriteEff(e1,1,"N")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FC","S")
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	WriteEff(e2,2,"O")
	c:RegisterEffect(e2)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IEMCard(Card.IsSummonType,tp,"M",0,1,nil,SUMMON_TYPE_SPECIAL)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		aux.DelayByTurn(tc,tp,1,ELABEL_IS_DELAYED_SUMMON)
		tc=eg:GetNext()
	end
end
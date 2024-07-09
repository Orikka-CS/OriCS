--¸£ºí¶û ÇÒ·Î¿ì
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.con2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"F","S")
	e3:SetCode(EFFECT_DISABLE)
	e3:SetTR("O","O")
	e3:SetCondition(s.con3)
	e3:SetTarget(s.tar3)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"FC","S")
	e4:SetCode(EVENT_CHAIN_SOLVING)
	WriteEff(e4,4,"NO")
	c:RegisterEffect(e4)
end
function s.nfil2(c)
	return c:IsFaceup() and c:IsSetCard("¸£ºí¶û")
end
function s.con2(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IEMCard(s.nfil2,tp,"O","O",1,nil)
end
function s.nfil3(c)
	return c:IsFaceup() and c:IsSetCard("¸£ºí¶û") and not c:IsCode(id)
end
function s.con3(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IEMCard(s.nfil3,tp,"O","O",1,nil)
end
function s.tar3(e,c)
	local handler=e:GetHandler()
	local g=handler:GetColumnGroup()
	return g:IsContains(c) and not c:IsSetCard("¸£ºí¶û")
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	local p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	return not rc:IsSetCard("¸£ºí¶û") and c:IsColumn(seq,p,LSTN("S"))
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
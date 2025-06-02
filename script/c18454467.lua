--sparkle.exe: Kawaii bug identity
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCondition(s.con2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"F","S")
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTR(0,1)
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"Qo","S")
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetCL(1,{id,1})
	WriteEff(e4,4,"CTO")
	c:RegisterEffect(e4)
end
function s.con2(e)
	local tp=e:GetHandlerPlayer()
	local cc=Duel.GetCurrentChain()
	if cc<=1 then
		return false
	end
	local cp0=Duel.GetChainInfo(cc-1,CHAININFO_TRIGGERING_PLAYER)
	local cp1=Duel.GetChainInfo(cc,CHAININFO_TRIGGERING_PLAYER)
	return tp==cp0 and tp==cp1
end
function s.val3(e,re,tp)
	local ep=e:GetHandlerPlayer()
	local cc=Duel.GetCurrentChain()
	local cp0=Duel.GetChainInfo(cc-2,CHAININFO_TRIGGERING_PLAYER)
	local cp1=Duel.GetChainInfo(cc-1,CHAININFO_TRIGGERING_PLAYER)
	local ce2,cp2=Duel.GetChainInfo(cc,CHAININFOF_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	local cc2=ce2:GetHandler()
	return ep==cp0 and ep~=cp1 and ep==cp2 and cc2:IsSetCard("sparkle.exe")
end
function s.cfil4(c,e,tp)
	local ec=e:GetHandler()
	return c:IsSetCard("sparkle.exe") and c:IsAbleToGraveAsCost()
		and Duel.IETarget(aux.TRUE,tp,"O","O",1,Group.FromCards(c,ec))
end
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.cfil4,tp,"HO",0,1,c,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.cfil4,tp,"HO",0,1,1,c,e,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsOnField() and chkc~=c
	end
	if chk==0 then
		return Duel.IETarget(aux.TRUE,tp,"O","O",1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.STarget(tp,aux.TRUE,tp,"O","O",1,1,c)
	Duel.SOI(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
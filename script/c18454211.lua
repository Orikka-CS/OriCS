--이매진 재뉴어리
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e2)	
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(10000)
	return true
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=(e:GetLabel()==0 or Duel.GetPlayerEffect(tp,EFFECT_JANUARY) or Duel.IEMCard(Card.IsDiscardable,tp,"H",0,101,nil))
	local b2=true
	if chk==0 then
		e:SetLabel(0)
		return b1 or b2
	end
	local discard=e:GetLabel()==10000
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	if op==1 then
		if discard then
			if Duel.GetPlayerEffect(tp,EFFECT_JANUARY) then
				local eset={Duel.GetPlayerEffect(tp,EFFECT_JANUARY)}
				local je=eset[1]
				Duel.Hint(HINT_CARD,0,je:GetHandler():GetCode())
				je:Reset()
			else
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
				local g=Duel.SMCard(tp,Card.IsDiscardable,tp,"H",0,101,101,nil)
				Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
			end
		end
		e:SetCategory(0)
	elseif op==2 then
		e:SetCategory(CATEGORY_RECOVER)
		Duel.SOI(0,CATEGORY_RECOVER,nil,0,tp,1010)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		local e1=MakeEff(c,"F")
		e1:SetCode(EFFECT_ACTIVATE_COST)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTR(0,1)
		e1:SetCost(s.ocost11)
		e1:SetOperation(s.oop11)
		Duel.RegisterEffect(e1,tp)
		local e2=MakeEff(c,"F")
		e2:SetCode(EFFECT_SUMMON_COST)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetTR(0xff,0xff)
		e2:SetCost(s.ocost12)
		e2:SetOperation(s.oop12)
		Duel.RegisterEffect(e2,tp)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_SPSUMMON_COST)
		Duel.RegisterEffect(e3,tp)
		local e4=e2:Clone()
		e4:SetCode(EFFECT_MSET_COST)
		Duel.RegisterEffect(e4,tp)
		e1:SetLabelObject({e1,e2,e3,e4})
		e2:SetLabelObject({e1,e2,e3,e4})
		e3:SetLabelObject({e1,e2,e3,e4})
		e4:SetLabelObject({e1,e2,e3,e4})
	elseif op==2 then
		Duel.Recover(tp,1010,REASON_EFFECT)
		local e1=MakeEff(c,"F")
		e1:SetCode(EFFECT_JANUARY)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTR(1,0)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.ocost11(e,te,tp)
	return Duel.IEMCard(aux.TRUE,tp,"H",0,101,nil)
end
function s.oop11(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SMCard(tp,aux.TRUE,tp,"H",0,101,101,nil)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	for _,te in ipairs(e:GetLabelObject()) do
		te:Reset()
	end
end
function s.ocost12(e,c,tp)
	return Duel.IEMCard(aux.TRUE,tp,"H",0,101,nil) or tp==e:GetHandlerPlayer()
end
function s.oop12(e,tp,eg,ep,ev,re,r,rp)
	if tp==e:GetHandlerPlayer() then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SMCard(tp,aux.TRUE,tp,"H",0,101,101,nil)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	for _,te in ipairs(e:GetLabelObject()) do
		te:Reset()
	end
end
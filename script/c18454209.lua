--재뉴어리 조커
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(10000)
	return true
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=(e:GetLabel()==0 or Duel.GetPlayerEffect(tp,EFFECT_JANUARY) or Duel.IEMCard(Card.IsDiscardable,tp,"H",0,101,nil))
		and Duel.IEMCard(aux.TRUE,tp,0,"H",1,nil)
	local b2=Duel.IEMCard(Card.IsAbleToRemove,tp,0,"H",1,nil)
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
		e:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
		Duel.SOI(0,CATEGORY_REMOVE,nil,1,1-tp,"H")
		Duel.SOI(0,CATEGORY_DRAW,nil,0,1-tp,1)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		local hg=Duel.GetFieldGroup(tp,0,LSTN("H"))
		if #hg>0 then
			Duel.ConfirmCards(tp,hg)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=hg:Select(tp,1,1,nil)
			Duel.HintSelection(g)
			Duel.SendtoHand(g,tp,REASON_EFFECT)
		end
	elseif op==2 then
		local hg=Duel.GetFieldGroup(tp,0,LSTN("H"))
		if not Duel.IsPlayerAffectedByEffect(1-tp,30459350) and #hg>0 then
			Duel.ConfirmCards(tp,hg)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g=hg:Select(tp,1,1,nil)
			local tc=g:GetFirst()
			local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			Duel.ShuffleHand(1-tp)
			local c=e:GetHandler()
			local fid=c:GetFieldID()
			local e1=MakeEff(c,"FC")
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCL(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.ocon11)
			e1:SetOperation(s.oop11)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
			if ct>0 then
				Duel.BreakEffect()
				Duel.Draw(1-tp,1,REASON_EFFECT)
			end
		end
		local e2=MakeEff(c,"F")
		e2:SetCode(EFFECT_JANUARY)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTR(1,0)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.ocon11(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
function s.oop11(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
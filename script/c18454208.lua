--재뉴어리 프라임
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DRAW)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(10000)
	return true
end
function s.cfil1(c)
	return c:IsSetCard("재뉴어리") and c:IsDiscardable()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local jan={Duel.GetPlayerEffect(tp,EFFECT_JANUARY)}
	local b1=(e:GetLabel()==0 or #jan>=2
		or (#jan==1 and Duel.IEMCard(Card.IsDiscardable,tp,"H",0,1,c))
		or Duel.IEMCard(Card.IsDiscardable,tp,"H",0,102,c))
		and Duel.IsPlayerCanDraw(tp,2)
	local b2=Duel.IEMCard(s.cfil1,tp,"H",0,1,c)
		and Duel.IsPlayerCanDraw(tp,2)
	if chk==0 then
		e:SetLabel(0)
		return b1 or b2
	end
	local discard=e:GetLabel()==10000
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	if discard then
		if op==1 then
			if #jan>=2 then
				local je1,je2=jan[1],jan[2]
				Duel.Hint(HINT_CARD,0,je1:GetHandler():GetCode())
				Duel.Hint(HINT_CARD,0,je2:GetHandler():GetCode())
				je1:Reset()
				je2:Reset()
			elseif #jan==1 then
				local je1=jan[1]
				Duel.Hint(HINT_CARD,0,je1:GetHandler():GetCode())
				je1:Reset()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
				local g=Duel.SMCard(tp,Card.IsDiscardable,tp,"H",0,1,1,nil)
				Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
			else
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
				local g=Duel.SMCard(tp,Card.IsDiscardable,tp,"H",0,102,102,nil)
				Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
			end
		elseif op==2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
			local g=Duel.SMCard(tp,s.cfil1,tp,"H",0,1,1,nil)
			Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
		end
	end
	Duel.SOI(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		Duel.Draw(tp,2,REASON_EFFECT)
	elseif op==2 then
		Duel.Draw(tp,2,REASON_EFFECT)
		local e1=MakeEff(c,"F")
		e1:SetCode(EFFECT_JANUARY)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTR(1,0)
		Duel.RegisterEffect(e1,tp)
	end
end
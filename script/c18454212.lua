--재뉴어리 알레프
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_CHAINING)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"A")
	e2:SetCode(EVENT_SUMMON)
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	WriteEff(e2,2,"NTO")
	WriteEff(e2,1,"C")
	c:RegisterEffect(e2)
	local e5=MakeEff(c,"S")
	e5:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e5)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER)) and Duel.IsChainNegatable(ev)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(10000)
	return true
end
function s.tfil1(c)
	return c:IsSetCard("재뉴어리") and c:IsFaceup()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=(e:GetLabel()==0 or Duel.GetPlayerEffect(tp,EFFECT_JANUARY) or Duel.IEMCard(Card.IsDiscardable,tp,"H",0,101,nil))
	local b2=c:IsLoc("S") and c:IsFacedown() and Duel.IEMCard(s.tfil1,tp,"O",0,1,nil)
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp~=tp
	if chk==0 then
		e:SetLabel(0)
		return b1 or b2
	end
	local discard=e:GetLabel()==10000
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	if op==1 and discard then
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
	Duel.SOI(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SOI(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	local rc=re:GetHandler()
	if op==1 then
		if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
			Duel.Destroy(eg,REASON_EFFECT)
		end
	elseif op==2 then
		if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
			Duel.Destroy(eg,REASON_EFFECT)
		end
		local e1=MakeEff(c,"F")
		e1:SetCode(EFFECT_JANUARY)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTR(1,0)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain(true)==0
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=(e:GetLabel()==0 or Duel.GetPlayerEffect(tp,EFFECT_JANUARY) or Duel.IEMCard(Card.IsDiscardable,tp,"H",0,101,nil))
	local b2=c:IsLoc("S") and c:IsFacedown() and Duel.IEMCard(s.tfil1,tp,"O",0,1,nil)
		and e:GetCode()==EVENT_SPSUMMON and ep~=tp
	if chk==0 then
		e:SetLabel(0)
		return b1 or b2
	end
	local discard=e:GetLabel()==10000
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	if op==1 and discard then
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
	Duel.SOI(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SOI(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	local rc=re:GetHandler()
	if op==1 then
		Duel.NegateSummon(eg)
		Duel.Destroy(eg,REASON_EFFECT)
	elseif op==2 then
		Duel.NegateSummon(eg)
		Duel.Destroy(eg,REASON_EFFECT)
		local e1=MakeEff(c,"F")
		e1:SetCode(EFFECT_JANUARY)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTR(1,0)
		Duel.RegisterEffect(e1,tp)
	end
end
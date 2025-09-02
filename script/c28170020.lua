--실락의 감귤천사
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DIVINE),2,2)
	local e1=MakeEff(c,"F","M")
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetD(id,0)
	e1:SetTR("H",0)
	e1:SetCondition(s.con1)
	e1:SetTarget(aux.FieldSummonProcTg(s.tar11,s.tar12))
	e1:SetOperation(s.op1)
	e1:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"Qo","M")
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetD(id,1)
	e3:SetCL(1,id)
	WriteEff(e3,3,"CTO")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"I","M")
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e4:SetD(id,2)
	e4:SetCL(1)
	WriteEff(e4,4,"CTO")
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"FTf","M")
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCategory(CATEGORY_RECOVER)
	e5:SetCL(1)
	WriteEff(e5,5,"NTO")
	c:RegisterEffect(e5)
end
function s.nfil1(c)
	return c:IsMonster() and c:IsAbleToDeckAsCost()
end
function s.con1(e,c,minc)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return minc<=2 and Duel.GetLocCount(tp,"M")>0
		and Duel.IEMCard(s.nfil1,tp,"G",0,2,nil)
end
function s.tar11(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi<=2 and ma>=2 and c:IsRace(RACE_DIVINE)
end
function s.tar12(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SMCard(tp,s.nfil1,tp,"G",0,2,2,true,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if not sg then
		return
	end
	Duel.HintSelection(sg)
	Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
	sg:DeleteGroup()
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckLPCost(tp,1000) or Duel.IsPlayerAffectedByEffect(tp,28170018)
	end
	if Duel.IsPlayerAffectedByEffect(tp,28170018) then
		Duel.Recover(tp,1000,REASON_EFFECT)
	else
		Duel.PayLPCost(tp,1000)
	end
end
function s.cfil3(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x2ce) and c:IsAbleToDeck()
		and c:CheckActivateEffect(true,true,false)~=nil
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then
		return Duel.IETarget(s.cfil3,tp,"G",0,1,nil)
	end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.STarget(tp,s.tfil3,tp,"G",0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	if tg then
		tg(e,tp,ceg,cep,cev,cre,cr,crp,1)
	end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then
		return
	end
	local tc=te:GetHandler()
	if not tc:IsRelateToEffect(e) then
		return
	end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then
		op(e,tp,eg,ep,ev,re,r,rp)
	end
	Duel.BreakEffect()
	Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
end
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		 return Duel.IEMCard(Card.IsDiscardable,tp,"H",0,1,nil)
	end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD)
end
function s.tfil4(c)
	return c:IsSetCard(0x2ce) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil4,tp,"D",0,1,nil)
	end
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil4,tp,"D",0,1,1,nil)
	aux.ToHandOrElse(g:GetFirst(),tp)
end
function s.con5(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	local ct=#Duel.GMGroup(aux.FaceupFilter(Card.IsRace,RACE_DIVINE),tp,"M","M",nil)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct*500)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*500)
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local ct=#Duel.GMGroup(aux.FaceupFilter(Card.IsRace,RACE_DIVINE),tp,"M","M",nil)
	Duel.Recover(tp,ct*500,REASON_EFFECT)
end
--감귤천사 디자이어
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(SUMMON_TYPE_TRIBUTE)
	e1:SetD(id,0)
	e1:SetCondition(s.con1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","M")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetD(id,1)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"Qo","M")
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetCL(1,id)
	WriteEff(e3,3,"CTO")
	c:RegisterEffect(e3)
end
function s.cfil1(c,tp)
	return c:IsRace(RACE_DIVINE) and (c:IsControler(tp) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c)>0
end
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	local mg=Duel.GMGroup(s.cfil1,tp,"M","M",nil,tp)
	return c:IsLevelAbove(7) and Duel.GetTributeCount(c,mg)>0
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,c)
	local mg=Duel.GMGroup(s.cfil1,tp,"M","M",nil,tp)
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:GetAttack()>=1000
	end
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(-1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToGrave()
	end
	if chk==0 then
		return Duel.IETarget(Card.IsAbleToGrave,tp,0,"O",1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.STarget(tp,Card.IsAbleToGrave,tp,0,"O",1,1,nil)
	Duel.SOI(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
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
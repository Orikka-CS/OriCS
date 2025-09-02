--감귤천사 유코백
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"STo")
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_TOGRAVE)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"Qo","M")
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetCL(1,id)
	WriteEff(e3,3,"CTO")
	c:RegisterEffect(e3)
end
function s.tfil1(c)
	return c:IsSetCard(0x2ce) and c:IsAbleToGrave()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOGRAVE,nil,1,tp,"D")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
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
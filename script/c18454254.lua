--功力狼 炔老钦脚
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetD(id,0)
	e2:SetValue(s.val2)
	e2:SetCondition(s.con2)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	local e3=MakeEff(c,"Qo","GR")
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCategory(CATEGORY_TOHAND)
	WriteEff(e3,3,"NCTO")
	c:RegisterEffect(e3)
end
function s.cfil1(c,tp)
	return c:IsSetCard("功力") and (c:IsAbleToGraveAsCost() or c:IsAbleToRemoveAsCost())
		and Duel.IEMCard(s.tfil1,tp,"H",0,1,c)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local lo=e:GetLabelObject()
	if chk==0 then
		lo:SetLabel(10000)
		return true
	end
	if lo:GetLabel()~=0 then
		lo:SetLabel(10000)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SMCard(tp,s.cfil1,tp,"HO",0,1,1,c,tp)
		local tc=g:GetFirst()
		if tc:IsAbleToGraveAsCost() and (not tc:IsAbleToRemoveAsCost() or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
			Duel.SendtoGrave(tc,REASON_COST)
		else
			Duel.Remove(tc,POS_FACEUP,REASON_COST)
		end
	end
end
function s.tfil1(c,e,ct)
	local ec=e:GetHandler()
	local mi,ma=c:GetTributeRequirement()
	local e1=MakeEff(ec,"S")
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.tfcon11)
	c:RegisterEffect(e1)
	local res=(mi==ct or ma==ct) and c:IsSetCard("功力") and c:IsSummonable(true,nil)
	e1:Reset()
	return res
end
function s.tfcon11(e,c,minc)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return minc==0 and Duel.GetLocCount(tp,"M")>0
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.CheckLPCost(tp,1000) and Duel.IEMCard(s.tfil1,tp,"H",0,1,nil,e,1)
	local b2=Duel.CheckLPCost(tp,2000) and Duel.IEMCard(s.tfil1,tp,"H",0,1,nil,e,2)
	if chk==0 then
		if e:GetLabel()~=10000 then
			return false
		end
		e:SetLabel(0)
		return (b1 or b2)
	end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	Duel.PayLPCost(tp,op*1000)
	e:SetLabel(op)
	Duel.SOI(0,CATEGORY_SUMMON,nil,1,tp,"H")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SMCard(tp,s.tfil1,tp,"H",0,1,1,nil,e,op)
	local tc=g:GetFirst()
	if tc then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCondition(s.tfcon11)
		tc:RegisterEffect(e1)
		local e2=MakeEff(tc,"FC")
		e2:SetCode(EVENT_MOVE)
		e2:SetLabelObject(e1)
		e2:SetOperation(s.oop12)
		Duel.RegisterEffect(e2,tp)
		Duel.Summon(tp,tc,true,nil)
	end	
end
function s.oop12(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if eg:IsContains(c) then
		local se=e:GetLabelObject()
		Duel.ResetFlagEffect(tp,id)
		se:Reset()
		e:Reset()
	end
end
function s.val2(e,c)
	e:SetLabel(1)
end
function s.con2(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	return Duel.IEMCard(s.cfil1,tp,"HO",0,1,c,tp)
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetTurnID()~=Duel.GetTurnCount() or c:IsReason(REASON_RETURN)
end
function s.cfil3(c)
	return c:IsSetCard("功力") and c:IsFaceup() and (c:IsAbleToRemoveAsCost() or c:IsLoc("R"))
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.cfil3,tp,"GR",0,1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SMCard(tp,s.cfil3,tp,"GR",0,1,1,c)
	local tc=g:GetFirst()
	if tc:IsLoc("G") then
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
	elseif tc:IsLoc("R") then
		Duel.SendtoGrave(tc,REASON_COST+REASON_RETURN)
	end
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToHand() or c:IsSSetable()
	end
	if c:IsLoc("G") then
		Duel.SOI(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
	Duel.SPOI(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		aux.ToHandOrElse(c,tp,Card.IsSSetable,function()
			Duel.SSet(tp,c)
		end,
		aux.Stringid(id,4))
	end
end
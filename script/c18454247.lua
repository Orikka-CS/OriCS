--功力狼 开锋没赴
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"I","HM")
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetCL(1,id)
	WriteEff(e2,2,"NCTO")
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_MOVE)
	WriteEff(e3,3,"N")
	c:RegisterEffect(e3)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToGraveAsCost() or c:IsAbleToRemoveAsCost()
	end
	if c:IsAbleToGraveAsCost() and (not c:IsAbleToRemoveAsCost()
		or Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
		Duel.SendtoGrave(c,REASON_COST)
	else
		Duel.Remove(c,POS_FACEUP,REASON_COST)
	end
end
function s.tfil11(c,tp)
	return (c:IsCode(80921533) or (c:IsCode(18454250) and Duel.GetFlagEffect(tp,id-10000)==0
		and Duel.IEMCard(s.tfil12,tp,"OGR",0,1,nil))) and c:IsType(TYPE_FIELD)
		and not c:IsForbidden() and (not c:IsLoc("R") or c:IsFaceup())
end
function s.tfil12(c)
	return c:IsCode(80921533) and c:IsFaceup()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil11,tp,"DGR",0,1,nil,tp)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SMCard(tp,s.tfil11,tp,"DGR",0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LSTN("F"),POS_FACEUP,true)
		if tc:IsCode(18454250) then
			Duel.RegisterFlagEffect(tp,id-10000,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LSTN("G"))
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckLPCost(tp,1000)
	end
	Duel.PayLPCost(tp,1000)
end
function s.tfil2(c,e)
	local ec=e:GetHandler()
	local mi,ma=c:GetTributeRequirement()
	local e1=MakeEff(ec,"S")
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.tfcon21)
	c:RegisterEffect(e1)
	local res=c:IsSetCard("功力") and (mi==1 or ma==1) and c:IsSummonable(true,nil)
	e1:Reset()
	return res
end
function s.tfcon21(e,c,minc)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return minc==0 and Duel.GetLocCount(tp,"M")>0
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.tfil2,tp,"H",0,1,nil,e)
	end
	Duel.SOI(0,CATEGORY_SUMMON,nil,1,tp,"H")
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SMCard(tp,s.tfil2,tp,"H",0,1,1,nil,e)
	local tc=g:GetFirst()
	if tc then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCondition(s.tfcon21)
		tc:RegisterEffect(e1)
		local e2=MakeEff(tc,"FC")
		e2:SetCode(EVENT_MOVE)
		e2:SetLabelObject(e1)
		e2:SetOperation(s.oop22)
		Duel.RegisterEffect(e2,tp)
		Duel.Summon(tp,tc,true,nil)
	end
end
function s.oop22(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if eg:IsContains(c) then
		local se=e:GetLabelObject()
		Duel.ResetFlagEffect(tp,id)
		se:Reset()
		e:Reset()
	end
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LSTN("R")) and c:IsLoc("G")
end
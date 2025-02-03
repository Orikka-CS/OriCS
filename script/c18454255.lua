--功力狼 噶阿邦急
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	WriteEff(e1,1,"C")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetD(id,0)
	e2:SetValue(s.val2)
	e2:SetCondition(s.con2)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	local e3=MakeEff(c,"F","S")
	e3:SetCode(EFFECT_SUMMON_PROC)
	e3:SetTR("H",0)
	e3:SetD(id,1)
	e3:SetCondition(s.con3)
	e3:SetTarget(aux.FieldSummonProcTg(aux.TargetBoolFunction(Card.IsSetCard,"功力"),s.tar3))
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"FTo","S")
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCategory(CATEGORY_SUMMON)
	e4:SetCL(1,id)
	WriteEff(e4,4,"NTO")
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_REMOVE)
	WriteEff(e5,5,"N")
	c:RegisterEffect(e5)
end
function s.cfil1(c)
	return c:IsSetCard("功力") and (c:IsLoc("R") or c:IsAbleToRemoveAsCost())
end
function s.cfun1(g)
	return g:FilterCount(Card.IsLoc,nil,"G")<=1
		and g:FilterCount(Card.IsLoc,nil,"R")<=1
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local lo=e:GetLabelObject()
	if chk==0 then
		lo:SetLabel(0)
		return true
	end
	if lo:GetLabel()~=0 then
		lo:SetLabel(0)
		local g=Duel.GMGroup(s.cfil1,tp,"GR",0,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:SelectSubGroup(tp,s.cfun1,true,2,2)
		local gg=sg:Filter(Card.IsLoc,nil,"G")
		local rg=sg:Filter(Card.IsLoc,nil,"R")
		Duel.Remove(gg,POS_FACEUP,REASON_COST)
		Duel.SendtoGrave(rg,REASON_COST+REASON_RETURN)		
	end
end
function s.val2(e,c)
	e:SetLabel(1)
end
function s.con2(e)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GMGroup(s.cfil1,tp,"GR",0,nil)
	return g:CheckSubGroup(s.cfun1,2,2)
end
function s.con3(e,c,minc)
	if c==nil then
		return true
	end
	local mi,ma=c:GetTributeRequirement()
	if mi~=1 and mi~=2 and ma~=1 and ma~=2 then
		return false
	end
	local tp=c:GetControler()
	local g=Duel.GMGroup(s.cfil1,tp,LSTN("GR"),0,nil)
	return minc==0 and Duel.GetLocCount(tp,"M")>0 and g:CheckSubGroup(s.cfun1,2,2)
		and Duel.GetFlagEffect(tp,id-10000)==0
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GMGroup(s.cfil1,tp,"GR",0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:SelectSubGroup(tp,s.cfun1,true,2,2)
	if sg and #sg==2 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else
		return false
	end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then
		return
	end
	local gg=g:Filter(Card.IsLoc,nil,"G")
	local rg=g:Filter(Card.IsLoc,nil,"R")
	Duel.Remove(gg,POS_FACEUP,REASON_COST)
	Duel.SendtoGrave(rg,REASON_COST+REASON_RETURN)
	Duel.RegisterFlagEffect(tp,id-10000,RESET_PHASE+PHASE_END,0,1)
	g:DeleteGroup()
end
function s.nfil4(c,tp)
	return c:IsSetCard("功力") and c:IsControler(tp)
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.nfil4,1,nil,tp)
end
function s.tfil4(c,e,tp)
	local ec=e:GetHandler()
	local e1=MakeEff(ec,"F")
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTR(1,0)
	e1:SetLabelObject(c)
	e1:SetTarget(s.tftar41)
	Duel.RegisterEffect(e1,tp)
	local res=c:IsSetCard("功力") and c:IsSummonable(true,nil)
	e1:Reset()
	return res
end
function s.tftar41(e,c,tp,sumtype)
	return sumtype&SUMMON_TYPE_TRIBUTE==SUMMON_TYPE_TRIBUTE and c==e:GetLabelObject()
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil4,tp,"H",0,1,nil,e,tp)
	end
	Duel.SOI(0,CATEGORY_SUMMON,nil,1,tp,"H")
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SMCard(tp,s.tfil4,tp,"H",0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		local e1=MakeEff(c,"F")
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTR(1,0)
		e1:SetLabelObject(tc)
		e1:SetTarget(s.tftar41)
		Duel.RegisterEffect(e1,tp)
		local e2=MakeEff(tc,"FC")
		e2:SetCode(EVENT_MOVE)
		e2:SetLabelObject(e1)
		e2:SetOperation(s.oop42)
		Duel.RegisterEffect(e2,tp)
		Duel.Summon(tp,tc,true,nil)
	end
end
function s.oop42(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if eg:IsContains(c) then
		local se=e:GetLabelObject()
		se:Reset()
		e:Reset()
	end
end
function s.nfil5(c,tp)
	return c:IsSetCard("功力") and c:IsControler(tp) and not c:IsPreviousLocation(LSTN("G"))
end
function s.con5(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.nfil5,1,nil,tp)
end
--功力狼 啊玫锐遏
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetD(id,0)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetCL(1,id)
	WriteEff(e2,2,"NCTO")
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"S")
	e4:SetCode(EFFECT_SUMMON_COST)
	WriteEff(e4,4,"O")
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"STo")
	e5:SetCode(EVENT_REMOVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCategory(CATEGORY_SUMMON)
	e5:SetCL(1,id)
	WriteEff(e5,5,"NCTO")
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_MOVE)
	WriteEff(e6,6,"N")
	c:RegisterEffect(e6)
end
function s.nfil1(c)
	return c:IsLoc("R") or c:IsAbleToRemoveAsCost()
end
function s.nfun1(g)
	return g:IsExists(Card.IsSetCard,1,nil,"功力")
		and g:FilterCount(Card.IsLoc,nil,"G")<=1
		and g:FilterCount(Card.IsLoc,nil,"R")<=1
end
function s.con1(e,c,minc)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.nfil1,tp,LSTN("GR"),0,nil)
	return Duel.GetLocCount(tp,"M")>0 and minc==0 and g:CheckSubGroup(s.nfun1,2,2)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(s.nfil1,tp,LSTN("GR"),0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:SelectSubGroup(tp,s.nfun1,true,2,2)
	if sg and #sg==2 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else
		return false
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then
		return
	end
	local gg=g:Filter(Card.IsLoc,nil,"G")
	local rg=g:Filter(Card.IsLoc,nil,"R")
	Duel.Remove(gg,POS_FACEUP,REASON_COST)
	Duel.SendtoGrave(rg,REASON_COST+REASON_RETURN)
	g:DeleteGroup()
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(id-10000)~=0 and c:IsSummonType(SUMMON_TYPE_NORMAL)
end
function s.cfil2(c)
	return c:IsAbleToGraveAsCost() or c:IsAbleToRemoveAsCost()
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.cfil2,tp,"HO",0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SMCard(tp,s.cfil2,tp,"HO",0,1,1,nil)
	local tc=g:GetFirst()
	if tc:IsAbleToGraveAsCost() and (not tc:IsAbleToRemoveAsCost() or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
		Duel.SendtoGrave(g,REASON_COST)
	else
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:GetLocation()==LOCATION_MZONE and chkc:GetControler()~=tp and chkc:IsControlerCanBeChanged()
	end
	if chk==0 then
		return Duel.IETarget(Card.IsControlerCanBeChanged,tp,0,"M",1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.STarget(tp,Card.IsControlerCanBeChanged,tp,0,"M",1,1,nil)
	Duel.SOI(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp)
	end
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetMaterialCount()==0 then
		c:RegisterFlagEffect(id-10000,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TOGRAVE-RESET_REMOVE-RESET_TEMP_REMOVE-RESET_LEAVE,0,0)
	else
		c:ResetFlagEffect(id-10000)
	end
end
function s.con5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LSTN("G"))
end
function s.cost5(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckLPCost(tp,2000)
	end
	Duel.PayLPCost(tp,2000)
end
function s.tfil5(c,e)
	local ec=e:GetHandler()
	local mi,ma=c:GetTributeRequirement()
	local e1=MakeEff(ec,"S")
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.tfcon51)
	c:RegisterEffect(e1)
	local res=c:IsSetCard("功力") and (mi==2 or ma==2) and c:IsSummonable(true,nil) and not c:IsCode(18454249)
	e1:Reset()
	return res
end
function s.tfcon51(e,c,minc)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return minc==0 and Duel.GetLocCount(tp,"M")>0
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.tfil5,tp,"H",0,1,nil,e)
	end
	Duel.SOI(0,CATEGORY_SUMMON,nil,1,tp,"H")
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SMCard(tp,s.tfil5,tp,"H",0,1,1,nil,e)
	local tc=g:GetFirst()
	if tc then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCondition(s.tfcon51)
		tc:RegisterEffect(e1)
		local e2=MakeEff(tc,"FC")
		e2:SetCode(EVENT_MOVE)
		e2:SetLabelObject(e1)
		e2:SetOperation(s.oop52)
		Duel.RegisterEffect(e2,tp)
		Duel.Summon(tp,tc,true,nil)
	end
end
function s.oop52(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if eg:IsContains(c) then
		local se=e:GetLabelObject()
		Duel.ResetFlagEffect(tp,id)
		se:Reset()
		e:Reset()
	end
end
function s.con6(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LSTN("R")) and c:IsLoc("G")
end
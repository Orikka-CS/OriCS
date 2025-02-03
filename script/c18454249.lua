--功力肺 泅脚茄 荤炔
local s,id=GetID()
function s.initial_effect(c)
	local e1=aux.AddNormalSummonProcedure(c,true,false,3,3)
	local con=e1:GetCondition()
	e1:SetCondition(function(e,c,...)
		local tp=e:GetHandlerPlayer()
		if Duel.GetFlagEffect(tp,80921533)~=0
			or Duel.GetFlagEffect(tp,id)~=0 then
			return false
		end
		return con(e,c,...)
	end)
	local e2=aux.AddNormalSetProcedure(c)
	local e3=MakeEff(c,"S")
	e3:SetCode(id)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"Qo","M")
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	WriteEff(e4,4,"NCTO")
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"STo")
	e5:SetCode(EVENT_REMOVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON)
	e5:SetCL(1,id)
	WriteEff(e5,5,"NTO")
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_MOVE)
	WriteEff(e6,6,"N")
	c:RegisterEffect(e6)
	local e7=MakeEff(c,"S")
	e7:SetCode(EFFECT_SUMMON_COST)
	WriteEff(e7,7,"O")
	c:RegisterEffect(e7)
	if not s.global_check then
		s.global_check=true
		s[0]={}
		s[1]={}
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	s[0]={}
	s[1]={}
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(id-10000)~=0
end
function s.cfil4(c,tp)
	if #s[tp]>0 and c:IsCode(table.unpack(s[tp])) then
		return false
	end
	return c:IsSetCard("功力") and c:IsFaceup() and (c:IsLoc("R") or c:IsAbleToRemoveAsCost())
end
function s.cfun4(g)
	return g:GetClassCount(Card.GetCode)==#g
		and g:FilterCount(Card.IsLoc,nil,"G")<=1
		and g:FilterCount(Card.IsLoc,nil,"R")<=1
end
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GMGroup(s.cfil4,tp,"GR",0,nil,tp)
	if chk==0 then
		return g:CheckSubGroup(s.cfun4,2,2)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:SelectSubGroup(tp,s.cfun4,false,2,2)
	local gg=sg:Filter(Card.IsLoc,nil,"G")
	local rg=sg:Filter(Card.IsLoc,nil,"R")
	local tc=sg:GetFirst()
	while tc do
		table.insert(s[tp],tc:GetCode())
		tc=sg:GetNext()
	end
	Duel.Remove(gg,POS_FACEUP,REASON_COST)
	Duel.SendtoGrave(rg,REASON_COST+REASON_RETURN)
end
function s.tfil4(c)
	return (c:IsLoc("R") or (not c:IsLoc("G") and c:IsAbleToGrave()))
		or (not c:IsLoc("R") and c:IsAbleToRemove()) or c:IsAbleToDeck()
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("OGR") and s.tfil4(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tfil4,tp,LSTN("OGR"),LSTN("OGR"),1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.tfil4,tp,LSTN("OGR"),LSTN("OGR"),1,1,nil)
	local tc=g:GetFirst()
	if tc:IsLoc("G") then
		Duel.SOI(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
	end
	Duel.SPOI(0,CATEGORY_TODECK,tc,1,0,0)
	if not tc:IsLoc("R") then
		Duel.SPOI(0,CATEGORY_REMOVE,tc,1,0,0)
	end
	if not tc:IsLoc("GR") then
		Duel.SPOI(0,CATEGORY_TOGRAVE,tc,1,0,0)
	end
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local b1=not tc:IsLoc("GR") and tc:IsAbleToGrave()
		local b2=not tc:IsLoc("R") and tc:IsAbleToRemove()
		local b3=tc:IsAbleToDeck()
		local b4=tc:IsLoc("R")
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)},
			{b3,aux.Stringid(id,3)},
			{b4,aux.Stringid(id,4)}
			)
		if op==1 then
			Duel.SendtoGrave(tc,REASON_EFFECT)
		elseif op==2 then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		elseif op==3 then
			Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
		elseif op==4 then
			Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
		end
	end
end
function s.con5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LSTN("G"))
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToHand()
	end
	Duel.SOI(0,CATEGORY_TOHAND,c,1,0,0)
	Duel.SPOI(0,CATEGORY_SUMMON,nil,1,tp,"H")
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLoc("H")
		and Duel.CheckLPCost(tp,3000) then
		Duel.RegisterFlagEffect(tp,id,0,0,0)
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCondition(s.ocon51)
		c:RegisterEffect(e1)
		local res=c:IsSummonable(true,nil)
		if res and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			local e2=MakeEff(c,"FC")
			e2:SetCode(EVENT_MOVE)
			e2:SetLabelObject(e1)
			e2:SetOperation(s.oop52)
			Duel.RegisterEffect(e2,tp)
			graish_notcost=true
			Duel.PayLPCost(tp,3000)
			graish_notcost=nil
			Duel.Summon(tp,c,true,nil)
		else
			Duel.ResetFlagEffect(tp,id)
			e1:Reset()
		end
	end
end
function s.ocon51(e,c,minc)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return minc==0 and Duel.GetLocCount(tp,"M")>0
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
function s.op7(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetMaterialCount()==0 then
		c:RegisterFlagEffect(id-10000,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,0)
	else
		c:ResetFlagEffect(id-10000)
	end
end
--功力狼 没碍疙陛
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"Qo","H")
	e1:SetCode(EVENT_CHAINING)
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetCL(1,id)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_SUMMON_COST)
	WriteEff(e2,2,"O")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"Qo","M")
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK)
	e3:SetCL(1,{id,1})
	WriteEff(e3,3,"NCTO")
	c:RegisterEffect(e3)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsLevelAbove(5)
end
function s.cfil11(c)
	return c:IsSetCard("功力") and not c:IsCode(id) and (c:IsAbleToGraveAsCost() or c:IsAbleToRemoveAsCost())
end
function s.cfun1(g)
	local fc=g:GetFirst()
	local nc=g:GetNext()
	return g:GetClassCount(Card.GetCode)==#g
		and ((fc:IsAbleToGraveAsCost() and nc:IsAbleToRemoveAsCost())
			or (nc:IsAbleToGraveAsCost() and fc:IsAbleToRemoveAsCost()))
end
function s.cfil12(c,g)
	local sg=g:Clone():RemoveCard(c)
	local tc=sg:GetFirst()
	return c:IsAbleToGraveAsCost() and tc:IsAbleToRemoveAsCost()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GMGroup(s.cfil11,tp,"D",0,nil)
	if chk==0 then
		return g:CheckSubGroup(s.cfun1,2,2)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:SelectSubGroup(tp,s.cfun1,false,2,2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local gg=sg:FilterSelect(tp,s.cfil12,1,1,nil,sg)
	local rg=sg:Sub(gg)
	Duel.SendtoGrave(gg,REASON_COST)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCondition(s.tcon11)
		c:RegisterEffect(e1)
		local res=c:IsSummonable(true,nil)
		e1:Reset()
		return res
	end
	Duel.SOI(0,CATEGORY_SUMMON,c,1,0,0)
end
function s.tcon11(e,c,minc)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return minc==0 and Duel.GetLocCount(tp,"M")>0
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCondition(s.tcon11)
		c:RegisterEffect(e1)
		if c:IsSummonable(true,nil) then
			local e2=MakeEff(c,"FC")
			e2:SetCode(EVENT_MOVE)
			e2:SetLabelObject(e1)
			e2:SetOperation(s.oop12)
			Duel.RegisterEffect(e2,tp)
			Duel.Summon(tp,c,true,nil)
		else
			e1:Reset()
		end
	end
end
function s.oop12(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if eg:IsContains(c) then
		local se=e:GetLabelObject()
		se:Reset()
		e:Reset()
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetMaterialCount()==0 then
		c:RegisterFlagEffect(id-10000,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,0)
	else
		c:ResetFlagEffect(id-10000)
	end
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(id-10000)~=0
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
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
function s.tfil3(c)
	return (c:IsAbleToRemove() or c:IsAbleToDeck())
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return false
	end
	if chk==0 then
		return Duel.IETarget(s.tfil3,tp,"G","G",1,nil)
			and Duel.IsExistingTarget(aux.TRUE,tp,LSTN("R"),LSTN("R"),1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.STarget(tp,s.tfil3,tp,"G","G",1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,LSTN("R"),LSTN("R"),1,1,nil)
	Duel.SOI(0,CATEGORY_LEAVE_GRAVE,g1,1,0,0)
	Duel.SPOI(0,CATEGORY_REMOVE,g1,1,0,0)
	Duel.SPOI(0,CATEGORY_TODECK,g1:Merge(g2),2,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	local tc=g:GetFirst()
	while tc do
		if tc:IsLoc("G") then
			if tc:IsAbleToDeck() and (not tc:IsAbleToRemove() or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
				Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
			elseif tc:IsAbleToRemove() then
				Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
			end
		elseif tc:IsLoc("R") then
			if tc:IsAbleToDeck() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
			else
				Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
			end
		end
		tc=g:GetNext()
	end
end
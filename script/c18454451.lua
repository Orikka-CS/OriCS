--그대는 천진난만한 밤의 희망
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetCL(1,18454431,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FC","D")
	e2:SetCode(EVENT_STARTUP)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCL(1,{18454431,1},EFFECT_COUNT_CODE_DUEL)
	WriteEff(e2,2,"O")
	c:RegisterEffect(e2)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.cfun1(sg,tp,exg,dg)
	local a=0
	for c in aux.Next(sg) do
		if dg:IsContains(c) then a=a+1 end
		for tc in aux.Next(c:GetEquipGroup()) do
			if dg:IsContains(tc) then a=a+1 end
		end
	end
	return #dg-a>=1
end
function s.cfil1(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_FAIRY)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsOnField() and chkc~=c
	end
	local dg=Duel.GMGroup(Card.IsCanBeEffectTarget,tp,0,"O",c,e)
	if chk==0 then
		if not Duel.IsPlayerCanDraw(tp,1) then
			return false
		end
		if e:GetLabel()==1 then
			e:SetLabel(0)
			return Duel.CheckReleaseGroupCost(tp,s.cfil1,1,false,s.cfun1,nil,dg)
		else
			return Duel.IETarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,c)
		end
	end
	if e:GetLabel()==1 then
		local sg=Duel.SelectReleaseGroupCost(tp,s.cfil1,1,1,false,s.cfun1,nil,dg)
		Duel.Release(sg,REASON_COST)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.STarget(tp,aux.TRUE,tp,0,"O",1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:Code()==18454451
		and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local mt=_G["c18454451"]
		local ct=0
		while true do
			if not mt.eff_ct[c][ct] then
				break
			end
			mt.eff_ct[c][ct]:Reset()
			ct=ct+1
		end
		mt.eff_ct[c]=nil
		c:Recreate(18454431)
		local nmt=_G["c18454431"]
		if nmt==nil or nmt.initial_effect==nil then
			local token=Duel.CreateToken(tp,18454431)
		end
		c:SetStatus(STATUS_INITIALIZING,true)
		nmt=_G["c18454431"]
		nmt.initial_effect(c)
		c:SetStatus(STATUS_INITIALIZING,false)
		c:CancelToGrave()
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IEMCard(Card.IsCode,tp,"D",0,2,nil,18454431) then
		Duel.Win(1-tp,0x0)
	end
end
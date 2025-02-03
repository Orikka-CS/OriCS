--功力 福海弊
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetD(id,0)
	e1:SetCondition(s.con1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","M")
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTR("M","M")
	e2:SetTarget(s.tar2)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"S")
	e3:SetCode(EFFECT_SUMMON_COST)
	WriteEff(e3,3,"O")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"STo")
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	WriteEff(e4,4,"NCTO")
	c:RegisterEffect(e4)
end
function s.con1(e,c,minc)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.GetLocCount(tp,"M")>0 and Duel.CheckLPCost(tp,1000) and minc==0
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,c)
	graish_notcost=true
	Duel.PayLPCost(tp,1000)
	graish_notcost=nil
end
function s.tar2(e,c)
	local handler=e:GetHandler()
	return c==handler or c==handler:GetBattleTarget()
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetMaterialCount()==0 then
		c:RegisterFlagEffect(id-10000,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,0)
	else
		c:ResetFlagEffect(id-10000)
	end
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(id-10000)~=0
end
function s.cfil4(c)
	return c:IsSetCard("功力") and not c:IsCode(id) and (c:IsAbleToGraveAsCost() or c:IsAbleToRemoveAsCost())
end
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.cfil4,tp,"D",0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.cfil4,tp,"D",0,1,1,nil)
	local tc=g:GetFirst()
	if tc:IsAbleToGraveAsCost() and (not tc:IsAbleToRemoveAsCost() or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
		Duel.SendtoGrave(tc,REASON_COST)
	else
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
	end
end
function s.tfil41(c)
	return (not c:IsLoc("R") or c:IsFaceup()) and c:IsSetCard("功力") and c:IsAbleToHand() and not c:IsCode(id)
end
function s.tfil42(c)
	return c:IsSetCard("功力") and c:IsAbleToGrave() and not c:IsCode(id)
end
function s.tfil43(c)
	return (not c:IsLoc("R") or c:IsFaceup()) and c:IsSetCard("功力") and (c:IsAbleToGrave() or c:IsLoc("R")) and not c:IsCode(id)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IEMCard(s.tfil41,tp,"DGR",0,1,nil) and Duel.GetFlagEffect(tp,id-10000)==0
	local b2=Duel.IEMCard(s.tfil42,tp,"DG",0,1,nil) and Duel.GetFlagEffect(tp,id-20000)==0
	local b3=Duel.IEMCard(s.tfil43,tp,"DR",0,1,nil) and Duel.GetFlagEffect(tp,id-30000)==0
	if chk==0 then
		return b1 or b2 or b3
	end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)},
		{b3,aux.Stringid(id,4)})
	e:SetLabel(op)
	if op==1 then
		Duel.RegisterFlagEffect(tp,id-10000,RESET_PHASE+PHASE_END,0,1)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"DGR")
	elseif op==2 then
		Duel.RegisterFlagEffect(tp,id-20000,RESET_PHASE+PHASE_END,0,1)
		e:SetCategory(CATEGORY_REMOVE)
		Duel.SOI(0,CATEGORY_REMOVE,nil,1,tp,"DG")
	elseif op==3 then
		Duel.RegisterFlagEffect(tp,id-30000,RESET_PHASE+PHASE_END,0,1)
		e:SetCategory(CATEGORY_TOGRAVE)
		Duel.SPOI(0,CATEGORY_TOGRAVE,nil,1,tp,"D")
	else
		e:SetCategory(0)
	end
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SMCard(tp,s.tfil41,tp,"DGR",0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SMCard(tp,s.tfil42,tp,"DR",0,1,1,nil)
		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	elseif op==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SMCard(tp,s.tfil43,tp,"DR",0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			if tc:IsLoc("D") then
				Duel.SendtoGrave(g,REASON_EFFECT)
			elseif tc:IsLoc("R") then
				Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
			end
		end
	end
end
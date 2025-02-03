--功力狼 技访荐拌
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetD(id,2)
	e1:SetCondition(s.con1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","HM")
	e2:SetCode(EVENT_CHAINING)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetCL(1,id)
	WriteEff(e2,2,"NCTO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"STo")
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e3:SetCL(1,id)
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_REMOVE)
	WriteEff(e4,4,"N")
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"S")
	e5:SetCode(EFFECT_SUMMON_COST)
	WriteEff(e5,5,"O")
	c:RegisterEffect(e5)
	if not s.global_check then
		s.global_check=true
		s[0]={}
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_CHAIN_END)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
		local ge2=MakeEff(c,"FC")
		ge2:SetCode(EVENT_TO_GRAVE)
		ge2:SetOperation(s.gop2)
		Duel.RegisterEffect(ge2,0)
		local ge3=MakeEff(c,"FC")
		ge3:SetCode(EVENT_REMOVE)
		ge3:SetOperation(s.gop3)
		Duel.RegisterEffect(ge3,0)
		local ge4=MakeEff(c,"FC")
		ge4:SetCode(EVENT_MOVE)
		ge4:SetOperation(s.gop4)
		Duel.RegisterEffect(ge4,0)
	end
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	s[0]={}
end
function s.gop2(e,tp,eg,ep,ev,re,r,rp)
	local cc=Duel.GetCurrentChain()
	if cc>0 then
		local ce=Duel.GetChainInfo(cc,CHAININFO_TRIGGERING_EFFECT)
		if re and re==ce and r&REASON_COST~=0 then
			if s[0][cc]==nil then
				s[0][cc]=1
			else
				s[0][cc]=s[0][cc]|1
			end
		end
	end
end
function s.gop3(e,tp,eg,ep,ev,re,r,rp)
	local cc=Duel.GetCurrentChain()
	if cc>0 then
		local ce=Duel.GetChainInfo(cc,CHAININFO_TRIGGERING_EFFECT)
		if re and re==ce and r&REASON_COST~=0 then
			if s[0][cc]==nil then
				s[0][cc]=2
			else
				s[0][cc]=s[0][cc]|2
			end
		end
	end
end
function s.gofil4(c,ae)
	local cr=c:GetReason()
	local re=c:GetReasonEffect()
	return re and re==ae and cr&REASON_COST~=0 and c:IsLoc("G") and c:IsPreviousLocation(LSTN("R"))
end
function s.gop4(e,tp,eg,ep,ev,re,r,rp)
	local cc=Duel.GetCurrentChain()
	if cc>0 then
		local ce=Duel.GetChainInfo(cc,CHAININFO_TRIGGERING_EFFECT)
		if eg:IsExists(s.gofil4,1,nil,ce) then
			if s[0][cc]==nil then
				s[0][cc]=1
			else
				s[0][cc]=s[0][cc]|1
			end
		end
	end
end
function s.con1(e,c,minc)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.GetLocCount(tp,"M")>0 and Duel.CheckLPCost(tp,2000) and minc==0
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,c)
	graish_notcost=true
	Duel.PayLPCost(tp,2000)
	graish_notcost=nil
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return s[0][ev]
end
function s.cfil2(c,ec)
	return c:IsSetCard("功力") and not c:IsCode(id)
		and ((c:IsAbleToGraveAsCost() and ec:IsAbleToRemoveAsCost())
			or (ec:IsAbleToGraveAsCost() and c:IsAbleToRemoveAsCost()))
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GMGroup(s.cfil2,tp,"D",0,nil,c)
	if chk==0 then
		return #g>0
	end
	if c:GetFlagEffect(id-10000)~=0 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:Select(tp,1,1,nil)
	local tc=sg:GetFirst()
	if c:IsAbleToGraveAsCost() and (not c:IsAbleToRemoveAsCost()
		or not tc:IsAbleToGraveAsCost() or Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
		Duel.SendtoGrave(c,REASON_COST)
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
	else
		Duel.SendtoGrave(tc,REASON_COST)
		Duel.Remove(c,POS_FACEUP,REASON_COST)
	end
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SOI(0,CATEGORY_RECOVER,nil,0,tp,5000)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Recover(tp,5000,REASON_EFFECT)~=0 and e:GetLabel()==1 and s[0][ev] and s[0][ev]&3==3 then
		Duel.SetLP(tp,Duel.GetLP(tp)*2)
	end
end
function s.tfil3(c,e)
	return c:IsSetCard("功力") and c:IsAbleToHand() and not c:IsCode(id)
		and c:IsCanBeEffectTarget(e) and c:IsFaceup()
end
function s.tfun3(g)
	return g:GetClassCount(Card.GetCode)==#g
		and g:FilterCount(Card.IsLoc,nil,"G")<=1
		and g:FilterCount(Card.IsLoc,nil,"R")<=1
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return false
	end
	local g=Duel.GMGroup(s.tfil3,tp,"GR",0,nil,e)
	if chk==0 then
		return g:CheckSubGroup(s.tfun3,1,2)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:SelectSubGroup(tp,s.tfun3,false,1,2)
	Duel.SetTargetCard(sg)
	Duel.SOI(0,CATEGORY_TOHAND,sg,#sg,0,0)
	if #sg==2 then
		Duel.SPOI(0,CATEGORY_TOGRAVE,nil,1,tp,"HO")
		Duel.SPOI(0,CATEGORY_REMOVE,nil,1,tp,"HO")
	end
end
function s.ofil3(c)
	return c:IsAbleToGrave() or c:IsAbleToRemove()
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		local ct=Duel.SendtoHand(g,nil,REASON_EFFECT)
		if ct>0 then
			Duel.ConfirmCards(1-tp,g)
			if ct==2 and g:FilterCount(Card.IsLoc,nil,"H")==2 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local sg=Duel.SMCard(tp,s.ofil3,tp,"HO",0,1,1,nil)
				Duel.HintSelection(sg)
				local tc=sg:GetFirst()
				if tc:IsAbleToGrave() and (not tc:IsAbleToRemove() or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
					Duel.SendtoGrave(sg,REASON_EFFECT)
				else
					Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
				end
			end
		end
	end
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsPreviousLocation(LSTN("G"))
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetMaterialCount()==0 then
		c:RegisterFlagEffect(id-10000,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,0)
	else
		c:ResetFlagEffect(id-10000)
	end
end
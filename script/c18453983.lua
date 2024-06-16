--“아이돌 따위”라고 함부로 말하지마
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"Qo","DHGR")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","DHGR")
	e2:SetCode(EFFECT_ACTIVATE_COST)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"S")
	e3:SetCode(EFFECT_IDOL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(function(e)
		local c=e:GetHandler()
		return not c:IsOnField()
	end)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"SC")
	e4:SetCode(EVENT_IDOL)
	WriteEff(e4,4,"O")
	c:RegisterEffect(e4)
	GlobalIdolCost[e4]=function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then
			return Duel.GetLocCount(tp,"M")>0
				or (c:IsLoc("H") and Duel.IEMCard(s.cfil4,tp,"O",0,1,nil,tp))
		end
		if c:IsLoc("H") then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local min=Duel.GetLocCount(tp,"M")>0 and 0 or 1
			local g=Duel.SMCard(tp,s.cfil4,tp,"O",0,0,1,nil,tp)
			if #g>0 then
				Duel.Release(g,REASON_COST)
			end
		end
		Duel.MoveToField(c,tp,tp,LSTN("M"),POS_FACEUP,true)
	end
	e3:SetLabelObject(e4)
	local e5=MakeEff(c,"FC")
	e5:SetCode(EVENT_ADJUST)
	e5:SetCondition(function(e,tp)
		local c=e:GetHandler()
		return c:IsControler(tp) or (c:IsControler(PLAYER_NONE) and c:GetOwner()==tp)
			and (c:IsLoc("DHGR") or c:GetLocation()==0)
			and not GlobalIdolStacked[e]
	end)
	WriteEff(e5,5,"O")
	Duel.RegisterEffect(e5,0)
	e5:SetProperty(0)
	local e6=e5:Clone()
	Duel.RegisterEffect(e6,1)
	e6:SetProperty(0)
	GlobalIdolCost[e5]=function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then
			return Duel.GetLocCount(tp,"M")>0 and (c:IsLoc("DHGR") or c:GetLocation()==0)
				or (c:IsLoc("H") and Duel.IEMCard(s.cfil4,tp,"O",0,1,nil,tp))
		end
		if not Duel.SelectEffectYesNo(tp,c,0) then
			e:SetLabel(0)
			return
		else
			e:SetLabel(1)
		end
		if c:IsLoc("H") then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local min=Duel.GetLocCount(tp,"M")>0 and 0 or 1
			local g=Duel.SMCard(tp,s.cfil4,tp,"O",0,0,1,nil,tp)
			if #g>0 then
				Duel.Release(g,REASON_COST)
			end
		end
		Duel.MoveToField(c,tp,tp,LSTN("M"),POS_FACEUP,true)
	end
	GlobalIdolCost[e6]=function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then
			return Duel.GetLocCount(tp,"M")>0 and (c:IsLoc("DHGR") or c:GetLocation()==0)
				or (c:IsLoc("H") and Duel.IEMCard(s.cfil4,tp,"O",0,1,nil,tp))
		end
		if not Duel.SelectEffectYesNo(tp,c,0) then
			e:SetLabel(0)
			return
		else
			e:SetLabel(1)
		end
		if c:IsLoc("H") then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local min=Duel.GetLocCount(tp,"M")>0 and 0 or 1
			local g=Duel.SMCard(tp,s.cfil4,tp,"O",0,0,1,nil,tp)
			if #g>0 then
				Duel.Release(g,REASON_COST)
			end
		end
		Duel.MoveToField(c,tp,tp,LSTN("M"),POS_FACEUP,true)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SMCard(tp,s.ofil4,tp,"O",0,0,10,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
	if c:IsRelateToEffect(e) and c:CanAttack() then
		Duel.CalculateDamage(c,nil)
	end
end
function s.cost2(e,te,tp)
	local tc=te:GetHandler()
	return Duel.GetLocCount(tp,"M")>0 or (tc:IsLoc("H") and Duel.IEMCard(s.cfil4,tp,"O",0,1,nil,tp))
end
function s.tar2(e,te,tp)
	local c=e:GetHandler()
	local tc=te:GetHandler()
	return c==tc
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLoc("H") then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local min=Duel.GetLocCount(tp,"M")>0 and 0 or 1
		local g=Duel.SMCard(tp,s.cfil4,tp,"O",0,0,1,nil,tp)
		if #g>0 then
			Duel.Release(g,REASON_COST)
		end
	end
	Duel.MoveToField(c,tp,tp,LSTN("M"),POS_FACEUP,false)
end
function s.cfil4(c,tp)
	return c:IsSetCard("아이돌") and Duel.GetMZoneCount(tp,c)>0
end
function s.ofil4(c)
	return c:IsSetCard("아이돌") and c:IsAbleToHand() and c:IsFaceup() and not c:IsCode(id)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SMCard(tp,s.ofil4,tp,"O",0,0,10,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
	if c:CanAttack() then
		Duel.CalculateDamage(c,nil)
	end
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SMCard(tp,s.ofil4,tp,"O",0,0,10,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
	if c:CanAttack() then
		Duel.CalculateDamage(c,nil)
	end
end
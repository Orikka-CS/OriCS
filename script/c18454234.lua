--영원히 기록될 은하린
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,11,3)
	local e1=MakeEff(c,"SC","M")
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","M")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCL(1)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
			and c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_CYBERSE)
	end
	return true
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetValue(ATTRIBUTE_DARK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(RACE_ZOMBIE)
	c:RegisterEffect(e2)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(10000)
	return true
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.GetFlagEffect(tp,id-10000)==0
	local b2=Duel.GetFlagEffect(tp,id-20000)==0
	if chk==0 then
		if e:GetLabel()~=10000 then
			return false
		end
		e:SetLabel(0)
		return (b1 or b2) and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	end
	e:SetLabel(0)
	local ct=1
	if b1 and b2 then
		ct=2
	end
	local sel=c:RemoveOverlayCard(tp,1,ct,REASON_COST)
	local op=0
	if sel==2 then
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
		op=3
		e:SetLabel(3)
	elseif sel==1 then
		op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
		e:SetLabel(op)
	end
	if op&1~=0 then
		Duel.RegisterFlagEffect(tp,id-10000,RESET_PHASE+PHASE_END,0,1)
	end
	if op&2~=0 then
		Duel.RegisterFlagEffect(tp,id-20000,RESET_PHASE+PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,0)
		local zone=Duel.SelectFieldZone(tp,1,LSTN("O"),LSTN("O"),0xe000e000)
		Duel.Hint(HINT_ZONE,tp,zone)
		Duel.Hint(HINT_ZONE,1-tp,((zone&0xffff)<<16)|(zone>>16))
		e:SetLabelObject({zone})
		Duel.RaiseEvent(Group.FromCards(c),18454238,e,REASON_COST,tp,tp,1)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op&1~=0 then
		local e1=MakeEff(c,"F")
		e1:SetCode(id)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTR(1,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
	if op&2~=0 then
		local zone=e:GetLabelObject()[1]
		local phase=Duel.GetCurrentPhase()
		if phase>PHASE_MAIN1 and phase<PHASE_MAIN2 then
			phase=PHASE_BATTLE
		end
		local e2=MakeEff(c,"FC")
		e2:SetCode(EVENT_ADJUST)
		e2:SetReset(RESET_PHASE+phase)
		e2:SetLabel(zone)
		e2:SetOperation(s.oop22)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.oop22(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetLabel()
	local player=nil
	local location=nil
	local sequence=nil
	for i=0,31 do
		if zone&(1<<i)~=0 then
			if i&0x10==0 then
				player=tp
			else
				player=1-tp
			end
			if i&0x8==0 then
				location=LOCATION_MZONE
			else
				location=LOCATION_SZONE
			end
			sequence=i&0x7
			break
		end
	end
	function ptoz(tp,player,location,sequence)
		local left=sequence
		if tp~=player then
			left=left+16
		end
		if location==LOCATION_SZONE then
			left=left+8
		end
		return 1<<left
	end
	local checks={}
	local group=Group.CreateGroup()
	local card=nil
	local forever=Duel.GetPlayerEffect(tp,18454234)
	if location==LOCATION_MZONE then
		if sequence==5 then
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,5))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,5)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,1-player,LOCATION_MZONE,3))
			card=Duel.GetFieldCard(1-player,LOCATION_MZONE,3)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,1))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,1)
			if card then
				group:AddCard(card)
			end
			if forever then
				table.insert(checks,ptoz(tp,1-player,LOCATION_SZONE,3))
				card=Duel.GetFieldCard(1-player,LOCATION_SZONE,3)
				if card then
					group:AddCard(card)
				end
				table.insert(checks,ptoz(tp,player,LOCATION_SZONE,1))
					card=Duel.GetFieldCard(player,LOCATION_SZONE,1)
				if card then
					group:AddCard(card)
				end
			end
		elseif sequence==6 then
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,6))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,6)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,1-player,LOCATION_MZONE,1))
			card=Duel.GetFieldCard(1-player,LOCATION_MZONE,1)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,3))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,3)
			if card then
				group:AddCard(card)
			end
			if forever then
				table.insert(checks,ptoz(tp,1-player,LOCATION_SZONE,1))
				card=Duel.GetFieldCard(1-player,LOCATION_SZONE,1)
				if card then
					group:AddCard(card)
				end
				table.insert(checks,ptoz(tp,player,LOCATION_SZONE,3))
					card=Duel.GetFieldCard(player,LOCATION_SZONE,3)
				if card then
					group:AddCard(card)
				end
			end
		elseif sequence==1 then
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,1))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,1)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,5))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,5)
			if card then
				group:AddCard(card)
			end
			card=Duel.GetFieldCard(1-player,LOCATION_MZONE,6)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_SZONE,1))
			card=Duel.GetFieldCard(player,LOCATION_SZONE,1)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,0))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,0)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,2))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,2)
			if card then
				group:AddCard(card)
			end
			if forever then
				table.insert(checks,ptoz(tp,1-player,LOCATION_MZONE,3))
				card=Duel.GetFieldCard(1-player,LOCATION_MZONE,3)
				if card then
					group:AddCard(card)
				end
				table.insert(checks,ptoz(tp,player,LOCATION_MZONE,3))
				card=Duel.GetFieldCard(player,LOCATION_MZONE,3)
				if card then
					group:AddCard(card)
				end
			end
		elseif sequence==3 then
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,3))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,3)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,6))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,6)
			if card then
				group:AddCard(card)
			end
			card=Duel.GetFieldCard(1-player,LOCATION_MZONE,5)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_SZONE,3))
			card=Duel.GetFieldCard(player,LOCATION_SZONE,3)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,2))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,2)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,4))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,4)
			if card then
				group:AddCard(card)
			end
			if forever then
				table.insert(checks,ptoz(tp,1-player,LOCATION_MZONE,1))
				card=Duel.GetFieldCard(1-player,LOCATION_MZONE,1)
				if card then
					group:AddCard(card)
				end
				table.insert(checks,ptoz(tp,player,LOCATION_MZONE,1))
				card=Duel.GetFieldCard(player,LOCATION_MZONE,1)
				if card then
					group:AddCard(card)
				end
			end
		elseif sequence==0 then
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,0))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,0)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_SZONE,0))
			card=Duel.GetFieldCard(player,LOCATION_SZONE,0)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,1))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,1)
			if card then
				group:AddCard(card)
			end
			if forever then
				table.insert(checks,ptoz(tp,player,LOCATION_MZONE,2))
				card=Duel.GetFieldCard(player,LOCATION_MZONE,2)
				if card then
					group:AddCard(card)
				end
			end
		elseif sequence==2 then
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,2))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,2)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_SZONE,2))
			card=Duel.GetFieldCard(player,LOCATION_SZONE,2)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,1))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,1)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,3))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,3)
			if card then
				group:AddCard(card)
			end
			if forever then
				table.insert(checks,ptoz(tp,player,LOCATION_MZONE,0))
				card=Duel.GetFieldCard(player,LOCATION_MZONE,0)
				if card then
					group:AddCard(card)
				end
				table.insert(checks,ptoz(tp,player,LOCATION_MZONE,4))
				card=Duel.GetFieldCard(player,LOCATION_MZONE,4)
				if card then
					group:AddCard(card)
				end
			end
		elseif sequence==4 then
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,4))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,4)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_SZONE,4))
			card=Duel.GetFieldCard(player,LOCATION_SZONE,4)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,3))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,3)
			if card then
				group:AddCard(card)
			end
			if forever then
				table.insert(checks,ptoz(tp,player,LOCATION_MZONE,2))
				card=Duel.GetFieldCard(player,LOCATION_MZONE,2)
				if card then
					group:AddCard(card)
				end
			end
		end
	elseif location==LOCATION_SZONE then
		if sequence==1 then
			table.insert(checks,ptoz(tp,player,LOCATION_SZONE,1))
			card=Duel.GetFieldCard(player,LOCATION_SZONE,1)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,1))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,1)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_SZONE,0))
			card=Duel.GetFieldCard(player,LOCATION_SZONE,0)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_SZONE,2))
			card=Duel.GetFieldCard(player,LOCATION_SZONE,2)
			if card then
				group:AddCard(card)
			end
			if forever then
				table.insert(checks,ptoz(tp,player,LOCATION_MZONE,5))
				card=Duel.GetFieldCard(player,LOCATION_MZONE,5)
				if card then
					group:AddCard(card)
				end
				card=Duel.GetFieldCard(1-player,LOCATION_MZONE,6)
				if card then
					group:AddCard(card)
				end
				table.insert(checks,ptoz(tp,player,LOCATION_SZONE,3))
				card=Duel.GetFieldCard(player,LOCATION_SZONE,3)
				if card then
					group:AddCard(card)
				end
			end
		elseif sequence==3 then
			table.insert(checks,ptoz(tp,player,LOCATION_SZONE,3))
			card=Duel.GetFieldCard(player,LOCATION_SZONE,3)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,3))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,3)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_SZONE,2))
			card=Duel.GetFieldCard(player,LOCATION_SZONE,2)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_SZONE,4))
			card=Duel.GetFieldCard(player,LOCATION_SZONE,4)
			if card then
				group:AddCard(card)
			end
			if forever then
				table.insert(checks,ptoz(tp,player,LOCATION_MZONE,6))
				card=Duel.GetFieldCard(player,LOCATION_MZONE,6)
				if card then
					group:AddCard(card)
				end
				card=Duel.GetFieldCard(1-player,LOCATION_MZONE,5)
				if card then
					group:AddCard(card)
				end
				table.insert(checks,ptoz(tp,player,LOCATION_SZONE,1))
				card=Duel.GetFieldCard(player,LOCATION_SZONE,1)
				if card then
					group:AddCard(card)
				end
			end
		elseif sequence==0 then
			table.insert(checks,ptoz(tp,player,LOCATION_SZONE,0))
			card=Duel.GetFieldCard(player,LOCATION_SZONE,0)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,0))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,0)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_SZONE,1))
			card=Duel.GetFieldCard(player,LOCATION_SZONE,1)
			if card then
				group:AddCard(card)
			end
			if forever then
				table.insert(checks,ptoz(tp,player,LOCATION_SZONE,2))
				card=Duel.GetFieldCard(player,LOCATION_SZONE,2)
				if card then
					group:AddCard(card)
				end
			end
		elseif sequence==2 then
			table.insert(checks,ptoz(tp,player,LOCATION_SZONE,2))
			card=Duel.GetFieldCard(player,LOCATION_SZONE,2)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,2))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,2)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_SZONE,1))
			card=Duel.GetFieldCard(player,LOCATION_SZONE,1)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_SZONE,3))
			card=Duel.GetFieldCard(player,LOCATION_SZONE,3)
			if card then
				group:AddCard(card)
			end
			if forever then
				table.insert(checks,ptoz(tp,player,LOCATION_SZONE,0))
				card=Duel.GetFieldCard(player,LOCATION_SZONE,0)
				if card then
					group:AddCard(card)
				end
				table.insert(checks,ptoz(tp,player,LOCATION_SZONE,4))
				card=Duel.GetFieldCard(player,LOCATION_SZONE,4)
				if card then
					group:AddCard(card)
				end
			end
		elseif sequence==4 then
			table.insert(checks,ptoz(tp,player,LOCATION_SZONE,4))
			card=Duel.GetFieldCard(player,LOCATION_SZONE,4)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_MZONE,4))
			card=Duel.GetFieldCard(player,LOCATION_MZONE,4)
			if card then
				group:AddCard(card)
			end
			table.insert(checks,ptoz(tp,player,LOCATION_SZONE,3))
			card=Duel.GetFieldCard(player,LOCATION_SZONE,3)
			if card then
				group:AddCard(card)
			end
			if forever then
				table.insert(checks,ptoz(tp,player,LOCATION_SZONE,2))
				card=Duel.GetFieldCard(player,LOCATION_SZONE,2)
				if card then
					group:AddCard(card)
				end
			end
		end
	end
	if #group>0 then
		local hints=0
		for i=1,#checks do
			local zone=checks[i]
			hints=hints|zone
		end
		Duel.Hint(HINT_ZONE,tp,hints)
		Duel.Hint(HINT_ZONE,1-tp,((hints&0xffff)<<16)|(hints>>16))
		Duel.HintSelection(group)
		Duel.Destroy(group,REASON_EFFECT)
		e:Reset()
	end
end
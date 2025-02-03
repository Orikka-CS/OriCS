--은하린 명예의 전당
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","F")
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTR("M",0)
	e2:SetTarget(s.tar2)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"FTo","F")
	e3:SetCode(EVENT_DESTROY)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"F","F")
	e4:SetCode(id)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTR(1,0)
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		s[0]=0
		s[1]=0
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
		local ge2=MakeEff(c,"FC")
		ge2:SetCode(id)
		ge2:SetOperation(s.gop2)
		Duel.RegisterEffect(ge2,0)
	end
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	s[0]=0
	s[1]=0
end
function s.gop2(e,tp,eg,ep,ev,re,r,rp)
	s[rp]=s[rp]+ev
end
function s.tar2(e,c)
	return c:IsSetCard("은하린")
end
function s.val2(e)
	local tp=e:GetHandlerPlayer()
	return s[tp]*100
end
function s.nfil3(c)
	return c:IsSetCard("은하린") and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsType(TYPE_FIELD)
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.nfil3,1,nil)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return true
	end
	Duel.Hint(HINT_SELECTMSG,tp,0)
	local zone=Duel.SelectFieldZone(tp,1,LSTN("O"),LSTN("O"),0xe000e000)
	Duel.Hint(HINT_ZONE,tp,zone)
	Duel.Hint(HINT_ZONE,1-tp,((zone&0xffff)<<16)|(zone>>16))
	e:SetLabel(zone)
	Duel.RaiseEvent(Group.FromCards(c),18454238,e,REASON_COST,tp,tp,1)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=e:GetLabel()
	local phase=Duel.GetCurrentPhase()
	if phase>PHASE_MAIN1 and phase<PHASE_MAIN2 then
		phase=PHASE_BATTLE
	end
	local e1=MakeEff(c,"FC")
	e1:SetCode(EVENT_ADJUST)
	e1:SetReset(RESET_PHASE+phase)
	e1:SetLabel(zone)
	e1:SetOperation(s.oop31)
	Duel.RegisterEffect(e1,tp)
end
function s.oop31(e,tp,eg,ep,ev,re,r,rp)
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
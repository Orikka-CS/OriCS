--은하린 전설의 시작
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
end
function s.tfil1(c)
	return c:IsSetCard("은하린") and c:IsAbleToHand() and not c:IsCode(id)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil)
	end
	local e1=MakeEff(c,"SC")
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetReset(RESET_CHAIN)
	e1:SetOperation(s.top11)
	Duel.RegisterEffect(e1,tp)
	Duel.Hint(HINT_SELECTMSG,tp,0)
	local exceptions=0xe060e060
	local hall=0
	if Duel.GetPlayerEffect(tp,18454238) then
		hall=LSTN("O")
		exceptions=0xe000e000
	else
		if Duel.GetFieldCard(tp,LSTN("M"),5) then
			exceptions=exceptions&(~0x400020)
		end
		if Duel.GetFieldCard(tp,LSTN("M"),6) then
			exceptions=exceptions&(~0x200040)
		end
	end
	local zone=Duel.SelectFieldZone(tp,1,LSTN("O"),hall,exceptions)
	Duel.Hint(HINT_ZONE,tp,zone)
	Duel.Hint(HINT_ZONE,1-tp,((zone&0xffff)<<16)|(zone>>16))
	e:SetLabel(zone)
	Duel.RaiseEvent(Group.FromCards(c),18454238,e,REASON_COST,tp,tp,1)
	local g=Duel.GMGroup(aux.TRUE,tp,"O","O",1,c)
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
	Duel.SPOI(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.top11(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) then
		c:RegisterFlagEffect(id-10000,RESET_CHAIN,0,0)
	end
	e:Reset()
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nli,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		if c:GetFlagEffect(id-10000)~=0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=Duel.SMCard(tp,aux.TRUE,tp,"O","O",0,1,nil)
			if #dg>0 then
				Duel.BreakEffect()
				Duel.HintSelection(dg)
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
	local zone=e:GetLabel()
	local phase=Duel.GetCurrentPhase()
	if phase>PHASE_MAIN1 and phase<PHASE_MAIN2 then
		phase=PHASE_BATTLE
	end
	local e1=MakeEff(c,"FC")
	e1:SetCode(EVENT_ADJUST)
	e1:SetReset(RESET_PHASE+phase)
	e1:SetLabel(zone)
	e1:SetOperation(s.oop11)
	Duel.RegisterEffect(e1,tp)
end
function s.oop11(e,tp,eg,ep,ev,re,r,rp)
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
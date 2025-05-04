--은하린 은하수 콘서트
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.con2)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		s[0]=false
		s[1]=false
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
		local ge2=MakeEff(c,"FC")
		ge2:SetCode(18454238)
		ge2:SetOperation(s.gop2)
		Duel.RegisterEffect(ge2,0)
	end
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	s[0]=false
	s[1]=false
end
function s.gop2(e,tp,eg,ep,ev,re,r,rp)
	s[rp]=true
end
function s.tfil1(c,e)
	return c:IsSetCard("은하린") and c:IsFaceup() and not c:IsCode(id) and c:IsCanBeEffectTarget(e)
end
function s.tfun1(g)
	return g:FilterCount(Card.IsType,nil,TYPE_MONSTER)<=1
		and g:FilterCount(Card.IsType,nil,TYPE_SPELL)<=1
		and g:FilterCount(Card.IsType,nil,TYPE_TRAP)<=1
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return false
	end
	local g=Duel.GMGroup(s.tfil1,tp,"OG",0,nil,e)
	if chk==0 then
		return #g>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local sg=g:SelectSubGroup(tp,s.tfun1,false,1,2)
	Duel.SetTargetCard(sg)
	Duel.SPOI(0,CATEGORY_TOHAND,sg,#sg,0,0)
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
	local zone=Duel.SelectFieldZone(tp,#sg,LSTN("O"),hall,exceptions)
	Duel.Hint(HINT_ZONE,tp,zone)
	Duel.Hint(HINT_ZONE,1-tp,((zone&0xffff)<<16)|(zone>>16))
	e:SetLabel(zone)
	Duel.RaiseEvent(Group.FromCards(c),18454238,e,REASON_COST,tp,tp,#sg)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	local tc=g:GetFirst()
	local sg=Group.CreateGroup()
	while tc do
		Duel.HintSelection(Group.FromCards(tc))
		local res=true
		local eff={tc:GetCardEffect(EFFECT_NECRO_VALLEY)}
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,tc) then
				res=false
			end
		end
		if tc:IsAbleToHand() and res and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			sg:AddCard(tc)
		else
			local e1=MakeEff(c,"S")
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_IMMEDIATELY_APPLY)
			e1:SetDescription(3110)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(s.oval11)
			e1:SetOwnerPlayer(tp)
			tc:RegisterEffect(e1)			
		end
		tc=g:GetNext()
	end
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
	local zone=e:GetLabel()
	local phase=Duel.GetCurrentPhase()
	if phase>PHASE_MAIN1 and phase<PHASE_MAIN2 then
		phase=PHASE_BATTLE
	end
	for i=0,31 do
		if zone&(1<<i)~=0 then
			local e2=MakeEff(c,"FC")
			e2:SetCode(EVENT_ADJUST)
			e2:SetReset(RESET_PHASE+phase)
			e2:SetLabel(1<<i)
			e2:SetOperation(s.oop12)
			Duel.RegisterEffect(e2,tp)
		end
	end
end
function s.oval11(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
function s.oop12(e,tp,eg,ep,ev,re,r,rp)
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
function s.con2(e)
	local tp=e:GetHandlerPlayer()
	return s[tp]
end
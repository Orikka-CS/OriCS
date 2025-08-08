--KR Spinel
local s,id=GetID()
local pos=POS_FACEUP|POS_FACEDOWN
function s.initial_effect(c)
	--일반인은 여기서 냉큼 꺼지시지!
	local e1a=Effect.CreateEffect(c)
	e1a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1a:SetCode(EVENT_STARTUP)
	e1a:SetRange(LOCATION_ALL)
	e1a:SetOperation(s.start_op)
	Duel.RegisterEffect(e1a,0)
	--"태초에 카드가 있었다"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_ALL)
	e2:SetOperation(s.create_op)
	c:RegisterEffect(e2)
	--시간을 멈춰라 마이 월드야~!
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,14))
	e3:SetOperation(s.turnskip_op)
	c:RegisterEffect(e3)
	--하지만 이렇게 간단하게 피했습니다
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(id,15))
	e4:SetTarget(s.move_tg)
	e4:SetOperation(s.move_op)
	c:RegisterEffect(e4)
	--왜그러지? 휘청거리고 있지 않나!
	local e5=e2:Clone()
	e5:SetDescription(aux.Stringid(99000094,0))
	e5:SetOperation(s.resolve_op)
	c:RegisterEffect(e5)
end
function s.start_op(e)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	if c:IsLocation(LOCATION_ALL) then
		Duel.DisableShuffleCheck()
		local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_ALL,LOCATION_ALL,nil,id)
		if #g>0 then
			Duel.SendtoDeck(g,nil,-2,REASON_RULE)
		end
		for i=1,5 do
			Debug.AddCard(id-i,tp,tp,LOCATION_EXTRA,i,POS_FACEUP)
		end
		Debug.AddCard(id,tp,tp,LOCATION_EXTRA,1,POS_FACEUP)
		Debug.ReloadFieldEnd()
		--오늘 이 도시는 전쟁터로 변한다!
		local e1b=Effect.CreateEffect(c)
		e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1b:SetCode(EVENT_FREE_CHAIN)
		e1b:SetRange(LOCATION_ALL)
		e1b:SetOperation(s.debug_op)
		Duel.RegisterEffect(e1b,0)
	end
end
function s.debug_op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_ALL,0,nil,99000094,99000095,99000096,99000097,99000098,id)
	if #g>0 then
		Duel.SendtoDeck(g,nil,-2,REASON_RULE)
	else
		for i=1,5 do
			Debug.AddCard(id-i,tp,tp,LOCATION_EXTRA,i,POS_FACEUP)
		end
		Debug.AddCard(id,tp,tp,LOCATION_EXTRA,1,POS_FACEUP)
		Debug.ReloadFieldEnd()
	end
end
function s.actfilter(c,e,tp,eg,ep,ev,re,r,rp,chain)
	if not c:IsType(TYPE_FIELD) and Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
	local te=c:GetActivateEffect()
	local pre={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_ACTIVATE)}
	if not c:IsSpellTrap() or not te or c:IsHasEffect(EFFECT_CANNOT_TRIGGER) then return false end
	if pre[1] then
		for i,eff in ipairs(pre) do
			local prev=eff:GetValue()
			if type(prev)~='function' or prev(eff,te,tp) then return false end
		end
	end
	local condition=te:GetCondition()
	local cost=te:GetCost()
	local target=te:GetTarget()
	if te:GetCode()==EVENT_CHAINING then
		if chain<=0 then return false end
		local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
		local tc=te2:GetHandler()
		local g=Group.FromCards(tc)
		local p=tc:GetControler()
		return (not condition or condition(te,tp,g,p,chain,te2,REASON_EFFECT,p)) and (not cost or cost(te,tp,g,p,chain,te2,REASON_EFFECT,p,0))
			and (not target or target(te,tp,g,p,chain,te2,REASON_EFFECT,p,0))
	elseif te:GetCode()==EVENT_FREE_CHAIN then
		return (not condition or condition(te,tp,eg,ep,ev,re,r,rp)) and (not cost or cost(te,tp,eg,ep,ev,re,r,rp,0))
			and (not target or target(te,tp,eg,ep,ev,re,r,rp,0))
	else
		local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
		return res and (not condition or condition(te,tp,teg,tep,tev,tre,tr,trp)) and (not cost or cost(te,tp,teg,tep,tev,tre,tr,trp,0))
			and (not target or target(te,tp,teg,tep,tev,tre,tr,trp,0))
	end
end
function s.create_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=nil
	repeat
		ac=Duel.AnnounceCard(tp)
		Duel.Hint(HINT_CARD,0,ac)
		local announce_token=Duel.CreateToken(tp,ac)
		op=0
		--자신에게 뾰로롱한다 / 상대에게 뾰로롱한다 / 카드명 재선언 / 발동 취소
		local you_and_i=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(99000094,15))
		if you_and_i==0 then
			if announce_token:IsMonster() then
				--자신 몬스터 존에 낸다 / 자신의 패에 넣는다 / 자신 덱의 맨 위에 놓는다 / 자신 덱의 맨 아래에 놓는다
				op=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5),aux.Stringid(id,6),aux.Stringid(id,7))+1
			end
			if announce_token:IsSpellTrap() then
				--자신 필드에 발동한다 / 자신의 패에 넣는다 / 자신 덱의 맨 위에 놓는다 / 자신 덱의 맨 아래에 놓는다
				op=Duel.SelectOption(tp,aux.Stringid(id,8),aux.Stringid(id,5),aux.Stringid(id,6),aux.Stringid(id,7))+10
			end
		elseif you_and_i==1 then
			if announce_token:IsMonster() then
				--상대 몬스터 존에 낸다 / 상대의 패에 넣는다 / 상대 덱의 맨 위에 놓는다 / 상대 덱의 맨 아래에 놓는다
				op=Duel.SelectOption(tp,aux.Stringid(id,9),aux.Stringid(id,10),aux.Stringid(id,11),aux.Stringid(id,12))+50
			end
			if announce_token:IsSpellTrap() then
				--상대 필드에 발동한다 / 상대의 패에 넣는다 / 상대의 덱 맨 위에 놓는다
				op=Duel.SelectOption(tp,aux.Stringid(id,13),aux.Stringid(id,10),aux.Stringid(id,11),aux.Stringid(id,12))+60
			end
		end
	until you_and_i==3
		or op==1 or op==2 or op==3 or op==4
		or op==10 or op==11 or op==12 or op==13
		or op==50 or op==51 or op==52 or op==53
		or op==60 or op==61 or op==62 or op==63
	local token=Duel.CreateToken(tp,ac)
	local oppo_token=Duel.CreateToken(1-tp,ac)
	-- Monster Card
	--
	--자신 몬스터 존에 낸다
	if op==1 then
		Duel.MoveToField(token,tp,tp,LOCATION_MZONE,pos,true,0x7f)
	--자신의 패에 넣는다
	elseif op==2 or op==11 then
		Duel.SendtoHand(token,tp,REASON_RULE)
	--자신 덱의 맨 위에 놓는다
	elseif op==3 or op==12 then
		Duel.SendtoDeck(token,tp,SEQ_DECKTOP,REASON_RULE)
		Duel.ConfirmCards(1-tp,token)
	--자신 덱의 맨 아래에 놓는다
	elseif op==4 or op==13 then
		Duel.SendtoDeck(token,tp,SEQ_DECKBOTTOM,REASON_RULE)
		Duel.ConfirmCards(1-tp,token)
	--
	--상대 몬스터 존에 낸다
	elseif op==50 then
		Duel.MoveToField(oppo_token,tp,1-tp,LOCATION_MZONE,pos,true,0x7f)
	--상대의 패에 넣는다
	elseif op==51 or op==61 then
		Duel.SendtoHand(oppo_token,1-tp,REASON_RULE)
	--상대 덱의 맨 위에 놓는다
	elseif op==52 or op==62 then
		Duel.SendtoDeck(oppo_token,1-tp,SEQ_DECKTOP,REASON_RULE)
		Duel.ConfirmCards(tp,oppo_token)
	--자신 덱의 맨 아래에 놓는다
	elseif op==53 or op==63 then
		Duel.SendtoDeck(oppo_token,1-tp,SEQ_DECKBOTTOM,REASON_RULE)
		Duel.ConfirmCards(tp,oppo_token)
	end
	-- Spell & Trap Card
	--
	--자신 필드에 발동한다
	if op==10 then
		local chain=Duel.GetCurrentChain()-1
		local tc=token
		if s.actfilter(tc,e,tp,eg,ep,ev,re,r,rp,chain) then
			local tpe=tc:GetType()
			local te=tc:GetActivateEffect()
			local tg=te:GetTarget()
			local co=te:GetCost()
			local op=te:GetOperation()
			e:SetCategory(te:GetCategory())
			e:SetProperty(te:GetProperty())
			Duel.ClearTargetCard()
			local loc=LOCATION_SZONE
			if (tpe&TYPE_FIELD)~=0 then
				loc=LOCATION_FZONE
				local fc=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
				if Duel.IsDuelType(DUEL_1_FIELD) then
					if fc then Duel.Destroy(fc,REASON_RULE) end
					fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
					if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
				else
					fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
					if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
				end
			end
			Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true)
			Duel.Hint(HINT_CARD,0,tc:GetCode())
			tc:CreateEffectRelation(te)
			if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
				tc:CancelToGrave(false)
			end
			if te:GetCode()==EVENT_CHAINING then
				local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
				local tc=te2:GetHandler()
				local g=Group.FromCards(tc)
				local p=tc:GetControler()
				if co then co(te,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
				if tg then tg(te,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
			elseif te:GetCode()==EVENT_FREE_CHAIN then
				if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
				if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
			else
				local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
				if co then co(te,tp,teg,tep,tev,tre,tr,trp,1) end
				if tg then tg(te,tp,teg,tep,tev,tre,tr,trp,1) end
			end
			Duel.BreakEffect()
			local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			if g then
				local etc=g:GetFirst()
				while etc do
					etc:CreateEffectRelation(te)
					etc=g:GetNext()
				end
			end
			tc:SetStatus(STATUS_ACTIVATED,true)
			if not tc:IsDisabled() then
				if te:GetCode()==EVENT_CHAINING then
					local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
					local tc=te2:GetHandler()
					local g=Group.FromCards(tc)
					local p=tc:GetControler()
					if op then op(te,tp,g,p,chain,te2,REASON_EFFECT,p) end
				elseif te:GetCode()==EVENT_FREE_CHAIN then
					if op then op(te,tp,eg,ep,ev,re,r,rp) end
				else
					local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
					if op then op(te,tp,teg,tep,tev,tre,tr,trp) end
				end
			else
				--insert negated animation here
			end
			Duel.RaiseEvent(Group.CreateGroup(tc),EVENT_CHAIN_SOLVED,te,0,tp,tp,Duel.GetCurrentChain())
			if g and tc:IsType(TYPE_EQUIP) and not tc:GetEquipTarget() then
				Duel.Equip(tp,tc,g:GetFirst())
			end
			tc:ReleaseEffectRelation(te)
			if etc then
				etc=g:GetFirst()
				while etc do
					etc:ReleaseEffectRelation(te)
					etc=g:GetNext()
				end
			end
		else
			Duel.SendtoHand(tc,tp,REASON_RULE)
		end
	--상대 필드에 발동한다
	elseif op==60 then
		local chain=Duel.GetCurrentChain()-1
		local tc=oppo_token
		local tp=1-tp
		if s.actfilter(tc,e,tp,eg,ep,ev,re,r,rp,chain) then
			local tpe=tc:GetType()
			local te=tc:GetActivateEffect()
			local tg=te:GetTarget()
			local co=te:GetCost()
			local op=te:GetOperation()
			e:SetCategory(te:GetCategory())
			e:SetProperty(te:GetProperty())
			Duel.ClearTargetCard()
			local loc=LOCATION_SZONE
			if (tpe&TYPE_FIELD)~=0 then
				loc=LOCATION_FZONE
				local fc=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
				if Duel.IsDuelType(DUEL_1_FIELD) then
					if fc then Duel.Destroy(fc,REASON_RULE) end
					fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
					if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
				else
					fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
					if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
				end
			end
			Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true)
			Duel.Hint(HINT_CARD,0,tc:GetCode())
			tc:CreateEffectRelation(te)
			if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
				tc:CancelToGrave(false)
			end
			if te:GetCode()==EVENT_CHAINING then
				local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
				local tc=te2:GetHandler()
				local g=Group.FromCards(tc)
				local p=tc:GetControler()
				if co then co(te,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
				if tg then tg(te,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
			elseif te:GetCode()==EVENT_FREE_CHAIN then
				if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
				if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
			else
				local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
				if co then co(te,tp,teg,tep,tev,tre,tr,trp,1) end
				if tg then tg(te,tp,teg,tep,tev,tre,tr,trp,1) end
			end
			Duel.BreakEffect()
			local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			if g then
				local etc=g:GetFirst()
				while etc do
					etc:CreateEffectRelation(te)
					etc=g:GetNext()
				end
			end
			tc:SetStatus(STATUS_ACTIVATED,true)
			if not tc:IsDisabled() then
				if te:GetCode()==EVENT_CHAINING then
					local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
					local tc=te2:GetHandler()
					local g=Group.FromCards(tc)
					local p=tc:GetControler()
					if op then op(te,tp,g,p,chain,te2,REASON_EFFECT,p) end
				elseif te:GetCode()==EVENT_FREE_CHAIN then
					if op then op(te,tp,eg,ep,ev,re,r,rp) end
				else
					local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
					if op then op(te,tp,teg,tep,tev,tre,tr,trp) end
				end
			else
				--insert negated animation here
			end
			Duel.RaiseEvent(Group.CreateGroup(tc),EVENT_CHAIN_SOLVED,te,0,tp,tp,Duel.GetCurrentChain())
			if g and tc:IsType(TYPE_EQUIP) and not tc:GetEquipTarget() then
				Duel.Equip(tp,tc,g:GetFirst())
			end
			tc:ReleaseEffectRelation(te)
			if etc then
				etc=g:GetFirst()
				while etc do
					etc:ReleaseEffectRelation(te)
					etc=g:GetNext()
				end
			end
		else
			Duel.SendtoHand(tc,tp,REASON_RULE)
		end
	end
end
function s.turnskip_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--prevent activations for the rest of that phase
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetCode(EFFECT_CANNOT_ACTIVATE)
	e0:SetTargetRange(1,1)
	e0:SetValue(1)
	e0:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e0,tp)
	--skip phases until Battle Phase
	local p=Duel.GetTurnPlayer()
	Duel.SkipPhase(p,PHASE_DRAW,RESET_PHASE|PHASE_END,1)
	Duel.SkipPhase(p,PHASE_STANDBY,RESET_PHASE|PHASE_END,1)
	Duel.SkipPhase(p,PHASE_MAIN1,RESET_PHASE|PHASE_END,1)
	Duel.SkipPhase(p,PHASE_BATTLE,RESET_PHASE|PHASE_END,1)
	Duel.SkipPhase(p,PHASE_MAIN2,RESET_PHASE|PHASE_END,1)
	Duel.SkipPhase(p,PHASE_END,RESET_PHASE|PHASE_END,1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_TURN)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_BP)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END,Duel.GetCurrentPhase()<=PHASE_END and 2 or 1)
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_EP)
	Duel.RegisterEffect(e3,tp)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_EP)
	e4:SetTargetRange(0,1)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)
end
function s.move_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local loc=LOCATION_MZONE|LOCATION_STZONE|LOCATION_PZONE
	if chkc then return chkc:IsLocation(loc) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectTarget(tp,aux.TRUE,tp,loc,loc,0,1,nil)
	if tc then Duel.HintSelection(tc) end
end
function s.move_op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local ttp=tc:GetControler()
	local p1,p2,i
	local loc=LOCATION_MZONE
	local ezone_check=true
	local typ_check=1
	local pd_seq=0
	if tc:IsLocation(LOCATION_SZONE) then
		loc=LOCATION_SZONE
		ezone_check=false
		typ_check=256
		if tc:IsLocation(LOCATION_PZONE) then
			if not Duel.CheckPendulumZones(tp) then return end
			if tc:IsControler(tp) then
				pd_seq=~(256|4096)
			else
				pd_seq=~(16777216|268435456)
			end
		end
	end
	if tc:IsControler(tp) then
		i=0
		p1=loc
		p2=0
	else
		i=16
		p2=loc
		p1=0
	end
	local seq=Duel.SelectDisableField(tp,1,p1,p2,pd_seq,ezone_check)
	if not seq then return end
	if tc:IsLocation(LOCATION_PZONE) then
		seq=seq>>i
		if tc:GetSequence()==0 then
			Duel.MoveSequence(tc,1-seq,LOCATION_PZONE)
		elseif tc:GetSequence()==4 then
			Duel.MoveSequence(tc,seq,LOCATION_PZONE)
		end
	else
		Duel.MoveSequence(tc,math.log(seq/typ_check,2)-i)
	end
end
function s.resolve_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=nil
	local op=nil
	repeat
		g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,0,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.HintSelection(tc)
			--표시 형식을 변경한다 / 컨트롤을 변경한다 / 1번 더 일반 소환한다 / 1번 더 특수 소환한다 / 발동 취소
			op=Duel.SelectOption(tp,aux.Stringid(99000094,1),aux.Stringid(99000094,2),aux.Stringid(99000094,3),aux.Stringid(99000094,4),aux.Stringid(99000094,15))
			if op==0 then
				local cpos=Duel.SelectPosition(tp,tc,pos)
				Duel.ChangePosition(tc,cpos)
			elseif op==1 then
				if tc:IsControler(tp) then
					Duel.GetControl(tc,1-tp)
				else
					Duel.GetControl(tc,tp)
				end
			elseif op==2 then
				Duel.RaiseEvent(tc,EVENT_SUMMON_SUCCESS,e,REASON_EFFECT,tp,tc:GetControler(),ev)
				Duel.RaiseSingleEvent(tc,EVENT_SUMMON_SUCCESS,e,REASON_EFFECT,tp,tc:GetControler(),ev)
				tc:SetStatus(STATUS_SUMMON_TURN,true)
			elseif op==3 then
				Duel.RaiseEvent(tc,EVENT_SPSUMMON_SUCCESS,e,REASON_EFFECT,tp,tc:GetControler(),ev)
				Duel.RaiseSingleEvent(tc,EVENT_SPSUMMON_SUCCESS,e,REASON_EFFECT,tp,tc:GetControler(),ev)
				tc:SetStatus(STATUS_SPSUMMON_TURN,true)
			end
		end
	until #g==0 or op==4
end
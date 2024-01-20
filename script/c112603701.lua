--쿠루미
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(function(e,c)
		return c:IsSetCard(0xe76) and not c:IsCode(id)
	end)
	e3:SetValue(function(e,te)
		return e:GetHandlerPlayer()~=te:GetHandlerPlayer()
	end)
	c:RegisterEffect(e3)
end
function s.cfil11(c)
	return (c:IsReleasable() or (c:IsLocation(LOCATION_HAND) and c:IsType(TYPE_SPELL+TYPE_TRAP)))
		and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function s.cfil12(c)
	return not c:IsCode(id)
end
function s.cfil13(c)
	return c:IsFaceup() and c:IsDisabled() and c:IsReleasable()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return true
	end
	local rg=Duel.GetReleaseGroup(tp)
	rg=rg:Filter(Card.IsFaceup,c)
	local sg=Duel.GetMatchingGroup(s.cfil11,tp,LOCATION_HAND+LOCATION_SZONE,0,c)
	rg:Merge(sg)
	rg=rg:Filter(s.cfil12,nil)
	if Duel.IsPlayerAffectedByEffect(tp,112603719) and c112603719 and c112603719[tp]
		and not c112603719[tp][id] then
		local ag=Duel.GetMatchingGroup(s.cfil13,tp,0,LOCATION_ONFIELD,nil)
		rg:Merge(ag)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=rg:Select(tp,0,1,nil)
	if #g>0 then
		Duel.Release(g,REASON_COST)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
local function groupfrombit(bit,p)
	local loc=(bit&0x7F>0) and LOCATION_MZONE or LOCATION_SZONE
	local seq=(loc==LOCATION_MZONE) and bit or bit>>8
	seq = math.floor(math.log(seq,2))
	local g=Group.CreateGroup()
	local function optadd(loc,seq)
		local c=Duel.GetFieldCard(p,loc,seq)
		if c then
			g:AddCard(c)
		end
	end
	optadd(loc,seq)
	if seq<=4 then
		if seq+1<=4 then optadd(loc,seq+1) end
		if seq-1>=0 then optadd(loc,seq-1) end
	end
	if loc==LOCATION_MZONE then
		if seq<5 then
			optadd(LOCATION_SZONE,seq)
			if seq==1 then optadd(LOCATION_MZONE,5) end
			if seq==3 then optadd(LOCATION_MZONE,6) end
		elseif seq==5 then
			optadd(LOCATION_MZONE,1)
		elseif seq==6 then
			optadd(LOCATION_MZONE,3)
		end
	else
		optadd(LOCATION_MZONE,seq)
	end
	return g
end
function s.tfil1(c)
	local loc=c:GetLocation()
	local seq=c:GetSequence()
	local p=c:GetConrtoler()
	local zone=0
	if loc&LOCATION_MZONE>0 then
		zone=(1<<seq)
	else
		zone=(1<<(seq+8))
	end
	local g=groupfrombit(zone,p)
	return g:IsExists(Card.IsNegatable,1,nil)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsOnField() and s.tfil1(chkc) and chkc:IsControler(1-tp)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tfil1,tp,0,LOCATION_ONFIELD,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,s.tfil1,tp,0,LOCATION_ONFIELD,1,1,nil)
	if e:GetLabel()==1 then
		Duel.SetChainLimit(s.tcl1(g:GetFirst()))
	end
end
function s.tcl1(c)
	return function(e,lp,tp)
		return e:GetHandler()~=c
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local loc=tc:GetLocation()
		local seq=tc:GetSequence()
		local p=tc:GetConrtoler()
		local zone=0
		if loc&LOCATION_MZONE>0 then
			zone=(1<<seq)
		else
			zone=(1<<(seq+8))
		end
		local g=groupfrombit(zone,p)
		for gc in aux.Next(g) do
			if gc:IsControler(1-tp) and gc:IsFaceup() then
				Duel.NegateRelatedChain(gc,RESET_TURN_SET)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
				gc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
				gc:RegisterEffect(e2)
				if gc:IsType(TYPE_TRAPMONSTER) then
					local e3=Effect.CreateEffect(c)
					e3:SetType(EFFECT_TYPE_SINGLE)
					e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
					e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
					gc:RegisterEffect(e3)
				end
			end
		end
		if e:GetLabel()==1 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			tc:RegisterEffect(e2)
		end
	end
end
--Sparkle Exeeeyy! (feat. Urutea)
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","F")
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTR("M",0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,"sparkle.exe"))
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"FTo","F")
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetCL(1,id)
	WriteEff(e4,4,"NCTO")
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	local e6=MakeEff(c,"FC","F")
	e6:SetCode(EVENT_CHAIN_SOLVING)
	WriteEff(e6,6,"NO")
	c:RegisterEffect(e6)
	if not s.global_check then
		s.global_check=true
		s[0]=0
		s[1]=0
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
		local ge2=MakeEff(c,"FC")
		ge2:SetCode(EVENT_CHAINING)
		ge2:SetOperation(s.gop2)
		Duel.RegisterEffect(ge2,0)
	end
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	s[0]=0
	s[1]=0
end
function s.gop2(e,tp,eg,ep,ev,re,r,rp)
	if ev<=2 then
		return
	end
	local cp0=Duel.GetChainInfo(ev-2,CHAININFO_TRIGGERING_PLAYER)
	local cp1=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_PLAYER)
	if rp==cp0 and rp~=cp1 then
		s[rp]=s[rp]+1
	end
end
function s.val2(e,c)
	local tp=e:GetHandlerPlayer()
	return s[tp]*300
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonLocation,1,nli,LSTN("HD"))
end
function s.cfil4(c)
	return c:IsSetCard("sparkle.exe") and c:IsAbleToGraveAsCost() and not c:IsType(TYPE_FIELD)
end
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.cfil4,tp,"HO",0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.cfil4,tp,"HO",0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsOnField() and chkc:IsNegatable()
	end
	if chk==0 then
		return Duel.IETarget(Card.IsNegatable,tp,"O","O",1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.STarget(tp,Card.IsNegatable,tp,"O","O",1,1,nil)
	Duel.SOI(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsNegatable() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=e1:Clone()
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e3)
		end
	end
end
function s.con6(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cc=Duel.GetCurrentChain()
	if cc<=2 then
		return false
	end
	local cp0=Duel.GetChainInfo(cc-2,CHAININFO_TRIGGERING_PLAYER)
	local cp1=Duel.GetChainInfo(cc-1,CHAININFO_TRIGGERING_PLAYER)
	local rc=re:GetHandler()
	return cp0==tp and cp1~=tp and rp==tp and rc:IsSetCard("sparkle.exe")
end
function s.op6(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_LILAC_ADDOP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTR(1,0)
	e1:SetLabel(Duel.GetCurrentChain())
	e1:SetReset(RESET_CHAIN)
	e1:SetCondition(s.ocon61)
	e1:SetOperation(s.oop61)
	Duel.RegisterEffect(e1,tp)
end
function s.ocon61(e,tp,eg,ep,ev,re,r,rp)
	return Duel.CheckChainUniqueness()
end
function s.oop61(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.CheckChainUniqueness() then
		return
	end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		return
	end
	local dam=Duel.GetCurrentChain()*100
	if Duel.Damage(1-tp,dam,REASON_EFFECT)>0 then
		local g=Duel.GMGroup(Card.IsFaceup,tp,0,"M",nil)
		local tc=g:GetFirst()
		while tc do
			local e1=MakeEff(c,"S")
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(-dam)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
			tc=g:GetNext()
		end
	end
end
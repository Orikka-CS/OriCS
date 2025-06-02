--sparkle.exe: But I'll keep on flying high
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","G")
	e2:SetCL(1,{id,1})
	e2:SetCost(aux.bfgcost)
	WriteEff(e2,2,"O")
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
		ge2:SetCode(EVENT_CHAINING)
		ge2:SetOperation(s.gop2)
		Duel.RegisterEffect(ge2,0)
	end
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	s[0]=false
	s[1]=false
end
function s.gop2(e,tp,eg,ep,ev,re,r,rp)
	if ev<=2 then
		return
	end
	local cp0=Duel.GetChainInfo(ev-2,CHAININFO_TRIGGERING_PLAYER)
	local cp1=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_PLAYER)
	if rp==cp0 and rp~=cp1 then
		s[rp]=true
	end
end
function s.tfil1(c,e,tp)
	return c:IsSetCard("sparkle.exe") and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand()
			or (s[tp] and Duel.GetLocCount(tp,"M")>0 and
				c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SEQUENCE,tp,false,false)))
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil,e,tp)
	end
	Duel.SPOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
	Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"D")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		aux.ToHandOrElse(tc,tp,function(c)
			return tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SEQUENCE,tp,false,false,POS_FACEUP)
				and s[tp] and Duel.GetLocCount(tp,"M")>0
		end,
		function(c)
			Duel.SpecialSummon(tc,SUMMON_TYPE_SEQUENCE,tp,tp,false,false,POS_FACEUP)
		end)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTR("O",0)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,"sparkle.exe"))
	e1:SetValue(s.oval21)
	Duel.RegisterEffect(e1,tp)
end
function s.oval21(e,re,rp)
	local tp=e:GetHandlerPlayer()
	local cc=Duel.GetCurrentChain()
	if cc<1 then
		return false
	end
	local cp=Duel.GetChainInfo(cc,CHAININFO_TRIGGERING_PLAYER)
	return rp~=tp and cp==tp
end
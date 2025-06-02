--sparkle.exe: Call me error, call me free
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.con2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"Qo","G")
	e3:SetCode(EVENT_CHAINING)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetCL(1,{id,1})
	WriteEff(e3,3,"NCTO")
	c:RegisterEffect(e3)
end
function s.tfil1(c,e,tp)
	return c:IsSetCard("sparkle.exe") and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand() or (Duel.GetLocCount(tp,"M")>0 and
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
				and Duel.GetLocCount(tp,"M")>0
		end,
		function(c)
			Duel.SpecialSummon(tc,SUMMON_TYPE_SEQUENCE,tp,tp,false,false,POS_FACEUP)
		end)
	end
end
function s.con2(e)
	local tp=e:GetHandlerPlayer()
	local cc=Duel.GetCurrentChain()
	if cc<=1 then
		return false
	end
	local cp0=Duel.GetChainInfo(cc-1,CHAININFO_TRIGGERING_PLAYER)
	local cp1=Duel.GetChainInfo(cc,CHAININFO_TRIGGERING_PLAYER)
	return tp==cp0 and tp==cp1
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	if ev<=1 then
		return false
	end
	local cp0=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_PLAYER)
	return tp==cp0 and rp~=tp and Duel.IsChainDisablable(ev)
end
function s.cfil3(c,typ)
	return c:IsSetCard("sparkle.exe") and c:IsType(typ) and c:IsAbleToRemoveAsCost()
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemoveAsCost() and Duel.IEMCard(s.cfil3,tp,"G",0,1,nil,TYPE_MONSTER)
			 and Duel.IEMCard(s.cfil3,tp,"G",0,1,nil,TYPE_SPELL)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SMCard(tp,s.cfil3,tp,"G",0,1,1,nil,TYPE_MONSTER)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SMCard(tp,s.cfil3,tp,"G",0,1,1,nil,TYPE_SPELL)
	g1:Merge(g2)
	g1:AddCard(c)
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SOI(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
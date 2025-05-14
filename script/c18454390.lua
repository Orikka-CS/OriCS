--이무기는 꽃피운다(드라군 아나콘다)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,2)
	local e1=MakeEff(c,"STo")
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCL(1,id)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","M")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsOnField()
	end
	if chk==0 then
		return Duel.IETarget(aux.TRUE,tp,"O","O",1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.STarget(tp,aux.TRUE,tp,"O","O",1,1,nil)
	Duel.SOI(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsReleasable() and Duel.CheckLPCost(tp,2000)
	end
	Duel.Release(c,REASON_COST)
	Duel.PayLPCost(tp,2000)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"G")
	local cc=Duel.GetCurrentChain()
	if cc>1 then
		local ce,cp=Duel.GetChainInfo(cc-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		if cp~=tp then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
			local cc=ce:GetHandler()
			Duel.SPOI(0,CATEGORY_DISABLE,cc,1,0,0)
		else
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"FC")
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCL(1)
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	e1:SetCondition(s.ocon21)
	e1:SetOperation(s.oop21)
	Duel.RegisterEffect(e1,tp)
	local cc=Duel.GetCurrentChain()
	if cc>1 then
		local cp=Duel.GetChainInfo(cc-1,CHAININFO_TRIGGERING_PLAYER)
		if cp~=tp and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.NegateEffect(cc-1)
		end
	end
end
function s.ocon21(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetLabel()
end
function s.oofil21(c,e,tp)
	return (c:IsLevel(2) or c:IsRank(2) or c:IsLink(2)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.oop21(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SMCard(tp,aux.NecroValleyFilter(s.oofil21),tp,"G",0,1,1,nil,e,tp)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--왕립 붕괴도서관
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SPELL,LSTN("P"))
	c:SetCounterLimit(COUNTER_SPELL,3)
	Pendulum.AddProcedure(c)
	local e1=MakeEff(c,"FC","P")
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(aux.chainreg)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FC","P")
	e2:SetCode(EVENT_CHAIN_SOLVED)
	WriteEff(e2,2,"O")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"I","P")
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	WriteEff(e3,3,"CTO")
	c:RegisterEffect(e3)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsSpellEffect() and c:GetFlagEffect(1)>0 then
		c:AddCounter(COUNTER_SPELL,1)
	end
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsCanRemoveCounter(tp,COUNTER_SPELL,3,REASON_COST)
	end
	c:RemoveCounter(tp,COUNTER_SPELL,3,REASON_COST)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.GetLocCount(tp,"M")>0
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SOI(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
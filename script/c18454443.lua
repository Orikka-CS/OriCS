--¿Õ¸³ Áß¾Óµµ¼­°ü
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SPELL)
	c:SetCounterLimit(COUNTER_SPELL,3)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SEARCH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","F")
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetD(id,0)
	e2:SetTR("HM",0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,70791313))
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"FC","F")
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	WriteEff(e3,3,"NO")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"FC","F")
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(aux.chainreg)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"FC","F")
	e5:SetCode(EVENT_CHAIN_SOLVED)
	WriteEff(e5,5,"O")
	c:RegisterEffect(e5)
end
s.counter_place_list={COUNTER_SPELL}
s.listed_names={70791313}
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsCanAddCounter(tp,COUNTER_SPELL,3,c)
	end
	c:AddCounter(COUNTER_SPELL,3)
end
function s.ofil1(c)
	return c:IsCode(70791313) and c:IsAbleToHand()
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.ofil1,tp,"D",0,0,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp,c)
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD-RESET_TOFIELD|RESET_PHASE|PHASE_END,0,1)
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:GetFlagEffect(id)~=0 and tc:IsCanAddCounter(COUNTER_SPELL,3-tc:GetCounter(COUNTER_SPELL))
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	tc:AddCounter(COUNTER_SPELL,3-tc:GetCounter(COUNTER_SPELL))
	tc:ResetFlagEffect(id)
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsSpellEffect() and c:GetFlagEffect(1)>0 then
		c:AddCounter(COUNTER_SPELL,1)
	end
end
function s.cost6(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsCanRemoveCounter(tp,COUNTER_SPELL,3,REASON_COST)
	end
	c:RemoveCounter(tp,COUNTER_SPELL,3,REASON_COST)
end
function s.tfil6(c)
	return c:IsSetCard("µµ¼­°ü") and not c:IsCode(id)
end
function s.tar6(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,LSTN("D"),0)>1 and Duel.IEMCard(s.tfil6,tp,"D",0,1,nil)
	end
end
function s.op6(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SMCard(tp,s.tfil6,tp,"D",0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc,0)
		Duel.ConfirmDecktop(tp,1)
	end
end
--왕립 카툰도서관
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SPELL)
	c:SetCounterLimit(COUNTER_SPELL,3)
	local e1=MakeEff(c,"F","H")
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.con1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"SC")
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	WriteEff(e2,2,"O")
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"S")
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	e5:SetCondition(s.con5)
	c:RegisterEffect(e5)
	local e6=MakeEff(c,"FC","M")
	e6:SetCode(EVENT_CHAINING)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetOperation(aux.chainreg)
	c:RegisterEffect(e6)
	local e7=MakeEff(c,"FC","M")
	e7:SetCode(EVENT_CHAIN_SOLVED)
	WriteEff(e7,7,"O")
	c:RegisterEffect(e7)
	local e8=MakeEff(c,"I","M")
	e8:SetCategory(CATEGORY_DRAW)
	WriteEff(e8,8,"CTO")
	c:RegisterEffect(e8)
end
s.listed_names={15259703}
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.GetLocCount(tp,"M")>0 and Duel.IEMCard(aux.FaceupFilter(Card.IsCode,15259703),tp,"O",0,1,nil)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function s.nfil5(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
function s.con5(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IEMCard(s.nfil4,tp,0,"M",1,nil)
		and Duel.IEMCard(aux.FaceupFilter(Card.IsCode,15259703),tp,"O",0,1,nil)
end
function s.op7(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsSpellEffect() and c:GetFlagEffect(1)>0 then
		c:AddCounter(COUNTER_SPELL,1)
	end
end
function s.cost8(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsCanRemoveCounter(tp,COUNTER_SPELL,3,REASON_COST)
	end
	c:RemoveCounter(tp,COUNTER_SPELL,3,REASON_COST)
end
function s.tar8(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SOI(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op8(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end
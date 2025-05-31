--왕립 공중도서관
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:EnableCounterPermit(COUNTER_SPELL)
	c:SetCounterLimit(COUNTER_SPELL,3)
	local e1=MakeEff(c,"F","HG")
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCL(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S","MG")
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetValue(70791313)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"FC","M")
	e3:SetCode(EFFECT_RCOUNTER_REPLACE+COUNTER_SPELL)
	WriteEff(e3,3,"NO")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"FC","M")
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(aux.chainreg)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"FC","M")
	e5:SetCode(EVENT_CHAIN_SOLVED)
	WriteEff(e5,5,"O")
	c:RegisterEffect(e5)
	local e6=MakeEff(c,"I","M")
	e6:SetCategory(CATEGORY_DRAW)
	WriteEff(e6,6,"CTO")
	c:RegisterEffect(e6)
end
s.counter_place_list={COUNTER_SPELL}
s.listed_names={70791313}
function s.nfil1(c,tp)
	return c:IsSetCard("도서관") and c:IsFaceup() and c:IsAbleToHandAsCost() and Duel.GetMZoneCount(tp,c)>0
end
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.IEMCard(s.nfil1,tp,"O",0,1,nil,tp)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SMCard(tp,s.nfil1,tp,"O",0,0,1,nil,tp)
	if #g>0 then
		e:SetLabelObject(g)
		g:KeepAlive()
		return true
	else
		return false
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then
		return
	end
	Duel.SendtoHand(g,nil,REASON_COST)
	g:DeleteGroup()
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return r&REASON_COST~=0 and re:IsActivated() and ep==tp and ev==3 and rc:GetCounter(COUNTER_SPELL)>=2
		and rc:IsCode(70791313)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	rc:RemoveCounter(tp,COUNTER_SPELL,2,REASON_EFFECT)
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
function s.tar6(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SOI(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op6(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end
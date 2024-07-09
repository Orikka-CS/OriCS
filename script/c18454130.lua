--¸£ºí¶û Æ®¸±·ÎÁö
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"F","H")
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","M")
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetTR("M",0)
	e2:SetTarget(s.tar2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"S","M")
	e3:SetCode(EFFECT_SET_CONTROL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCondition(s.con3)
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"Qo","M")
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCL(1)
	e4:SetCondition(Duel.IsMainPhase)
	WriteEff(e4,4,"CTO")
	c:RegisterEffect(e4)
end
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.IEMCard(aux.TRUE,tp,"H",0,1,c) and Duel.GetLocCount(tp,"M")>0
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,aux.TRUE,tp,"H",0,0,1,c)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else
		return false
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.SendtoHand(g,1-tp,REASON_COST)
	g:DeleteGroup()
end
function s.tar2(e,c)
	return not c:IsSetCard("¸£ºí¶û")
end
function s.con3(e)
	return Duel.IsBattlePhase()
end
function s.val3(e,c)
	local handler=e:GetHandler()
	return handler:GetOwner()
end
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToChangeControler() and Duel.GetLocCount(1-tp,"M",tp,LOCATION_REASON_CONTROL)>0
	end
	Duel.GetControl(c,1-tp)
end
function s.tfil4(c,e,tp)
	return c:IsSetCard("¸£ºí¶û") and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocCount(1-tp,"M")>1 and Duel.IEMCard(s.tfil4,tp,"D",0,1,nil,e,tp)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"D")
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocCount(1-tp,"M")<=0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SMCard(tp,s.tfil4,tp,"D",0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_FACEUP)
	end
end
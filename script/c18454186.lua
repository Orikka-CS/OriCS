--로드 오브 툰드라
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	local e1=MakeEff(c,"F","H")
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"SC")
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	WriteEff(e2,2,"O")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"S")
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetCondition(s.con3)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"Qo","M")
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCL(1,id)
	WriteEff(e4,4,"CTO")
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"Qo","G")
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetCL(1,{id,1})
	e5:SetCost(aux.bfgcost)
	WriteEff(e5,5,"TO")
	c:RegisterEffect(e5)
end
s.listed_names={15259703}
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,aux.TRUE,1,false,1,true,c,tp,nil,false,nil)
		and Duel.IEMCard(aux.FaceupFilter(Card.IsCode,15259703),tp,"O",0,1,nil)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocCount(tp,"M")
	local g=Duel.SelectReleaseGroup(tp,aux.TRUE,1,1,false,true,true,c,nil,nil,false,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then
		return
	end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function s.nfil3(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
function s.con3(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IEMCard(s.nfil3,tp,0,"M",1,nil)
end
function s.cfil4(c,ft,tp)
	return c:IsFaceup() and c:IsType(TYPE_TOON) and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5))
end
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocCount(tp,"M")
	if chk==0 then
		return ft>-1 and Duel.CheckReleaseGroupCost(tp,s.cfil4,1,false,nil,nil,ft,tp)
	end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfil4,1,1,false,nil,nil,ft,tp)
	Duel.Release(g,REASON_COST)
end
function s.tfil4(c,e,tp)
	return c:IsType(TYPE_TOON) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:IsLevelAbove(6)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil4,tp,"D",0,1,nil,e,tp)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"D")
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocCount(tp,"M")<=0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SMCard(tp,s.tfil4,tp,"D",0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
function s.tfil5(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x62) and c:IsFaceup() and c:IsAbleToHand()
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("OG") and chkc:IsControler(tp) and s.tfil5(chkc)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil5,tp,"OG",0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.STarget(tp,s.tfil5,tp,"OG",0,1,1,nil)
	Duel.SOI(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

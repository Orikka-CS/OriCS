--프로그 오브 툰드라
local s,id=GetID()
function s.initial_effect(c)
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
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"S")
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(s.con4)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"I","M")
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetCL(1)
	WriteEff(e5,5,"CTO")
	c:RegisterEffect(e5)
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
function s.nfil4(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
function s.con4(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IEMCard(s.nfil4,tp,0,"M",1,nil)
end
function s.cfil5(c,ft,tp)
	return c:IsFaceup() and c:IsType(TYPE_TOON) and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5))
end
function s.tfil51(c,e,tp)
	return c:IsSetCard(0x1062) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.tfil52(c,e,tp)
	return c:IsType(TYPE_TOON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.cost5(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocCount(tp,"M")
	local b1=Duel.IEMCard(s.tfil51,tp,"D",0,1,nil,e,tp)
	local b2=Duel.IEMCard(s.tfil52,tp,"D",0,1,nil,e,tp) and Duel.GetFlagEffect(tp,id)==0
	if chk==0 then
		return ft>-1 and ((Duel.CheckReleaseGroupCost(tp,s.cfil5,1,false,nil,nil,ft,tp) and b1)
			or (Duel.CheckReleaseGroupCost(tp,s.cfil5,1,false,nil,c,ft,tp) and b2))
	end
	local sg=nil
	if b2 and not b1 then
		sg=Duel.SelectReleaseGroupCost(tp,s.cfil5,1,1,false,nil,c,ft,tp)
	else
		sg=Duel.SelectReleaseGroupCost(tp,s.cfil5,1,1,false,nil,nil,ft,tp)
	end
	e:SetLabelObject(sg:GetFirst())
	Duel.Release(sg,REASON_COST)
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"D")
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocCount(tp,"M")<=0 then
		return
	end
	local g=Duel.GMGroup(s.tfil51,tp,"D",0,nil,e,tp)
	local lo=e:GetLabelObject()
	if Duel.GetFlagEffect(tp,id)==0 and lo~=c then
		local sg=Duel.GMGroup(s.tfil52,tp,"D",0,nil,e,tp)
		g:Merge(sg)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,1,nil)
	if #sg>0 then
		local sc=sg:GetFirst()
		if not sc:IsSetCard(0x1062) then
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end

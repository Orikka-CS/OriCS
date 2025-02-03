--¸£ºí¶û ±×¶óÆÄÀÌÆ®
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"F","G")
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","M")
	e2:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTR(0xff,0xff)
	e2:SetTarget(s.tar2)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"S","M")
	e3:SetCode(EFFECT_SET_CONTROL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCondition(s.con3)
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"Qo","M")
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_CONTROL+CATEGORY_SPECIAL_SUMMON)
	e4:SetCL(1)
	e4:SetCondition(Duel.IsMainPhase)
	WriteEff(e4,4,"CTO")
	c:RegisterEffect(e4)
end
function s.nfil1(c,tp)
	return c:IsSetCard("¸£ºí¶û") and c:IsFaceup() and c:IsAbleToHandAsCost() and not c:IsCode(id)
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
	return c:IsSetCard("¸£ºí¶û")
end
function s.val2(e,c)
	if not c then
		return false
	end
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp)
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
	return not c:IsSetCard("¸£ºí¶û")
		and ((c:IsLoc("G") and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
			or (c:IsLoc("M") and c:IsAbleToChangeControler()))
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsLoc("MG") and chkc:IsControler(1-tp) and s.tfil1(chkc,e,tp)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil4,tp,0,"MG",1,exc,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.STarget(tp,s.tfil4,tp,0,"MG",1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		if tc:IsLoc("G") then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
		elseif tc:IsLoc("M") then
			e:SetCategory(CATEGORY_CONTROL)
			Duel.SOI(0,CATEGORY_CONTROL,g,1,0,0)
		end
	end
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if tc:IsLoc("G") then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		elseif tc:IsLoc("M") then
			Duel.GetControl(tc,tp)
		end
	end
end
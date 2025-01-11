--화이트 아이스 툰드라 곤
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,9,2,s.pfil1,aux.Stringid(id,0))
	local e1=MakeEff(c,"SC")
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(s.con2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"I","M")
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetD(id,1)
	e3:SetCL(1)
	e3:SetCost(aux.dxmcostgen(1,1,nil))
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"Qo","M")
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetD(id,2)
	e4:SetCL(1)
	WriteEff(e4,4,"CTO")
	c:RegisterEffect(e4)
end
function s.pfil1(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON) and c:IsRace(RACE_DRAGON)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function s.nfil2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
function s.con2(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IEMCard(s.nfil3,tp,0,"M",1,nil)
end
function s.tfil31(c,tp)
	return c:IsSetCard(0x62) and c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and not Duel.IEMCard(s.tfil32,tp,"OG",0,1,nil,c:GetCode())
end
function s.tfil32(c,code)
	return c:IsCode(code)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil31,tp,"D",0,1,nil,tp)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil31,tp,"D",0,1,1,nil,tp)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.cfil4(c,e,tp,ft)
	local lv=c:GetOriginalLevel()
	return lv>1 and c:IsType(TYPE_TOON) and c:IsAbleToGraveAsCost()
		and (c:IsLoc("H") or c:IsFaceup())
		and (ft>0 or (c:IsControler(tp) and c:IsLoc("M") and c:GetSequence()<5))
		and Duel.IETarget(s.tfil4,tp,"G",0,1,nil,e,tp,lv)
end
function s.tfil4(c,e,tp,lv)
	return c:IsType(TYPE_TOON) and c:IsLevelBelow(lv-1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocCount(tp,"M")
	if chkc then
		return chkc:IsLoc("G") and chkc:IsControler(tp) and s.tfil4(chkc,e,tp,e:GetLabel())
	end
	if chk==0 then
		if e:GetLabel()~=1 then
			return false
		end
		e:SetLabel(0)
		return ft>-1 and Duel.IEMCard(s.cfil4,tp,"HM",0,1,nil,e,tp,ft)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local cg=Duel.SMCard(tp,s.cfil4,tp,"HM",0,1,1,nil,e,tp,ft)
	Duel.SendtoGrave(cg,REASON_COST)
	local cc=cg:GetFirst()
	local lv=cc:GetLevel()
	e:SetLabel(lv)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.STarget(tp,s.tfil4,tp,"G",0,1,1,nil,e,tp,lv)
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
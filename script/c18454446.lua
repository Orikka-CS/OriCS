--sparkle.exe: Boot it up, my heart goes beep
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSequenceProcedure(c,nil,s.pfil1,1,99,s.pfil2,1,99,aux.TRUE,1,99)
	local e1=MakeEff(c,"Qo","H")
	e1:SetCode(EVENT_CHAINING)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCL(1,id)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function s.pfil1(tp,re,rp)
	local rc=re:GetHandler()
	return rc:IsSetCard("sparkle.exe")
end
function s.pfil2(tp,re,rp)
	return re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	if ev<=1 or rp==tp then
		return false
	end
	local cp=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_PLAYER)
	return cp==tp
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:IsPublic()
	end
	Duel.ConfirmCards(1-tp,c)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonLocation(LSTN("HD"))
end
function s.tfil2(c,label)
	return c:IsSetCard("sparkle.exe") and not c:IsCode(id)
		and (c:IsAbleToGrave() or (label==1 and c:IsAbleToHand()))
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if c:IsSummonType(SUMMON_TYPE_SEQUENCE) then
			e:SetLabel(1)
		else
			e:SetLabel(0)
		end
		return Duel.IEMCard(s.tfil2,tp,"D",0,1,nil,e:GetLabel())
	end
	if e:GetLabel()==1 then
		e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SPOI(0,CATEGORY_TOGRAVE,nil,1,tp,"D")
		Duel.SPOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
	else
		e:SetCategory(CATEGORY_TOGRAVE)
		Duel.SOI(0,CATEGORY_TOGRAVE,nil,1,tp,"D")
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil2,tp,"D",0,1,1,nil,e:GetLabel())
	local tc=g:GetFirst()
	if tc then
		if e:GetLabel()==1 then
			aux.ToHandOrElse(tc,tp)
		else
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
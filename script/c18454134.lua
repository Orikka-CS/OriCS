--¸£ºí¶û ½ºÅ¸°ÔÀÌÆ®
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,10,3,s.pfil1,aux.Stringid(id,0),2,s.pop1)
	local e1=MakeEff(c,"STf")
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","M")
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTR(0xff,0)
	e2:SetValue(LSTN("R"))
	e2:SetTarget(s.tar2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"S","M")
	e3:SetCode(EFFECT_SET_CONTROL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCondition(s.con3)
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
end
function s.pfil1(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard("¸£ºí¶û")
end
function s.pop1(e,tp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetFlagEffect(tp,id)==0
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	local e1=MakeEff(c,"S","M")
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE-RESET_TOFIELD)
	e1:SetValue(1875)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	e2:SetValue(1700)
	c:RegisterEffect(e2)
	return true
end
function s.cfil1(c)
	return c:IsSetCard("¸£ºí¶û") and c:IsAbleToGraveAsCost()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	local b2=c:IsAbleToChangeControler() and Duel.GetLocCount(1-tp,"M",tp,LOCATION_REASON_CONTROL)>0
	if chk==0 then
		return (b1 or b2) and Duel.IEMCard(s.cfil1,tp,"D",0,1,nil)
	end
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	if op==1 then
		c:RemoveOverlayCard(tp,1,1,REASON_COST)
	elseif op==2 then
		Duel.GetControl(c,1-tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.cfil1,tp,"D",0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tfil1(c)
	return c:IsSetCard("¸£ºí¶û") and c:IsType(TYPE_MONSTER)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("G") and chkc:IsControler(tp) and s.tfil1(chkc)
	end
	if chk==0 then
		return true
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.STarget(tp,s.tfil1,tp,"G",0,1,1,nil)
	Duel.SPOI(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then
		return
	end
	aux.ToHandOrElse(tc,tp,
		function(sc)
			return sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) and Duel.GetLocCount(1-tp,"M")>0
		end,
		function(sc)
			Duel.SpecialSummon(sc,0,tp,1-tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,2)
	)
end
function s.tar2(e,c)
	local tp=e:GetHandlerPlayer()
	return c:GetOwner()==tp and Duel.IsPlayerCanRemove(tp,c) and not c:IsSetCard("¸£ºí¶û")
end
function s.con3(e)
	return Duel.IsBattlePhase()
end
function s.val3(e,c)
	local handler=e:GetHandler()
	return handler:GetOwner()
end
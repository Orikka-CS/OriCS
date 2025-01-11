--툰드라쿤
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,2)
	local e1=MakeEff(c,"SC")
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(s.con2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"STo")
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"F","M")
	e4:SetCode(EFFECT_DISABLE)
	e4:SetTR("M","M")
	e4:SetTarget(s.tar4)
	c:RegisterEffect(e4)
end
s.listed_names={15259703}
function s.pfil1(c,lc,sumtype,tp)
	return c:IsType(TYPE_TOON,lc,sumtype,tp) and not c:IsLink(1)
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
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.tfil31(c,e,tp,zone)
	return c:IsType(TYPE_TOON) and (c:IsAbleToHand() or (Duel.GetFlagEffect(tp,id)==0 and Duel.GetLocCount(tp,"M")>0
		and Duel.IEMCard(s.tfil32,tp,"O",0,1,nil) and zone~=0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP,tp,zone)))
end
function s.tfil32(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	if chk==0 then
		return Duel.IEMCard(s.tfil31,tp,"D",0,1,nil,e,tp,zone)
	end
	if Duel.GetFlagEffect(tp,id)==0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
		Duel.SPOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
		Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"D")
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
	end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil31,tp,"D",0,1,1,nil,e,tp,zone)
	local tc=g:GetFirst()
	if tc then
		if c:IsRelateToEffect(e) and zone~=0 and Duel.GetFlagEffect(tp,id)==0
			and Duel.IEMCard(s.tfil32,tp,"O",0,1,nil) then
			aux.ToHandOrElse(tc,tp,function(c)
					return tc:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP,tp,zone)
						and Duel.GetLocCount(tp,"M")>0
				end,
				function(c)
					Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP,zone)
					Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
				end,
				aux.Stringid(id,0)
			)
		else
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
function s.tar4(e,c)
	local h=e:GetHandler()
	return h:GetLinkedGroup():IsContains(c) and c:IsType(TYPE_EFFECT)
end
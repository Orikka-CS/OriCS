--이그자리온 유니좀비
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"Qo","M")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCL(1,id)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FTo","G")
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
end
s.listed_names={18454422,71466592,13026402}
function s.nfil1(c)
	return c:IsFaceup() and c:IsLevelBelow(3)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IEMCard(s.nfil1,tp,"M",0,1,nil)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsReleasable()
	end
	Duel.Release(c,REASON_COST)
end
function s.tfil1(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and c:IsCode(18454422,71466592,13026402)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetMZoneCount(tp,c)>0 and Duel.IEMCard(s.tfil1,tp,"HDG",0,1,nil,e,tp)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"HDG")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocCount(tp,"M")
	if ft<=0 then
		return
	end
	local g=Duel.GMGroup(s.tfil1,tp,"HDG",0,nil,e,tp)
	if #g<=0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if ft>3 then
		ft=3
	end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		ft=1
	end
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	local tc=sg:GetFirst()
	while tc do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		local e1=MakeEff(c,"F","M")
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetCondition(s.ocon11)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		tc=sg:GetNext()
	end
	Duel.SpecialSummonComplete()
end
function s.ocon11(e)
	local c=e:GetHandler()
	if c:IsDefensePos() then
		return true
	end
	e:Reset()
	return false
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetTurnID()==Duel.GetTurnCount() and not c:IsReason(REASON_RETURN)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=c:IsAbleToHand()
	local b2=not Duel.IEMCard(s.nfil1,tp,"M",0,1,nil) and Duel.GetLocCount(tp,"M")>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
	if chk==0 then
		return b1 or b2
	end
	Duel.SPOI(0,CATEGORY_TOHAND,c,1,0,0)
	Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then
		return
	end
	aux.ToHandOrElse(c,tp,
		function(sc)
			return sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
				and Duel.GetLocCount(tp,"M")>0 and not Duel.IEMCard(s.nfil1,tp,"M",0,1,nil)
		end,
		function(sc)
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end,
		aux.Stringid(id,0)
	)
end
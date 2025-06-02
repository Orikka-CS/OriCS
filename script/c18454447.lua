--sparkle.exe: Crashin' dreams I couldn't keep
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSequenceProcedure(c,nil,s.pfil1,1,99,s.pfil2,1,99,aux.TRUE,1,99)
	local e1=MakeEff(c,"Qo","H")
	e1:SetCode(EVENT_CHAINING)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetCL(1,id)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo","G")
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
end
function s.pfil1(tp,re,rp)
	local rc=re:GetHandler()
	return rc:IsSetCard("sparkle.exe")
end
function s.pfil2(tp,re,rp)
	local rc=re:GetHandler()
	return rc:IsRace(RACE_SPELLCASTER|RACE_PSYCHIC|RACE_ZOMBIE)
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
function s.tfil1(c)
	return c:IsSetCard("sparkle.exe")
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"H",0,1,nil) and Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SOI(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SOI(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SMCard(tp,s.tfil1,tp,"H",0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function s.tfil2(c,e,tp,label)
	return c:IsSetCard("sparkle.exe") and not c:IsCode(id) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand()
			or (label==1 and Duel.GetLocCount(tp,"M")>0
				and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)))
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if c:IsSummonType(SUMMON_TYPE_SEQUENCE) then
			e:SetLabel(1)
		else
			e:SetLabel(0)
		end
		return Duel.IEMCard(s.tfil2,tp,"D",0,1,nil,e,tp,e:GetLabel())
	end
	if e:GetLabel()==1 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
		Duel.SPOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
		Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"D")
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SOI(0,CATEGORY_TOHAND+CATEGORY_SEARCH,nil,1,tp,"D")
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local label=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil2,tp,"D",0,1,1,nil,e,tp,label)
	local tc=g:GetFirst()
	if tc then
		aux.ToHandOrElse(tc,tp,function(c)
			return tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
				and label==1 and Duel.GetLocCount(tp,"M")>0
		end,
		function(c)
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end)
	end
end
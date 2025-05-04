--용기 있는 자가 미인을 얻는가
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"STo")
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	--temp
	local e2=MakeEff(c,"FC")
	e2:SetCode(EVENT_ADJUST)
	e2:SetLabel(0)
	WriteEff(e2,2,"O")
	Duel.RegisterEffect(e2,0)
	local e3=MakeEff(c,"STo")
	e3:SetCode(EVENT_BURNED)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
end
function s.tfil1(c)
	return c:IsCode(18454319) and c:IsAbleToHand()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"DO",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"DO")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil1,tp,"DO",0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local label=e:GetLabel()
	local burned=false
	for p=0,1 do
		local bz=aux.BurningZone[p]
		for i=1,#bz do
			local bc=bz[i]
			if bc==c then
				burned=p
				break
			end
		end
		if burned then
			break
		end
	end
	if burned then
		e:SetLabel(1)
		if label==0 then
			Duel.RaiseSingleEvent(c,EVENT_BURNED,e,0,burned,burned,0)
			Duel.RaiseEvent(Group.FromCards(c),EVENT_BURNED,e,0,burned,burned,0)
		end
	else
		e:SetLabel(0)
	end
end
function s.tfil3(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsType(TYPE_NORMAL)
		and c:IsCanBeEffectTarget(e)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local bz=aux.BurningZone[tp]
	local og=Group.CreateGroup()
	for i=1,#bz do
		og:AddCard(bz[i])
	end
	if chkc then
		return og:IsContains(chkc) and s.tfil3(chkc,e,tp)
	end
	if chk==0 then
		return og:IsExists(s.tfil3,1,nil,e,tp) and Duel.GetLocCount(tp,"M")>0
	end
	local g=og:FilterSelect(tp,s.tfil3,1,1,nil,e,tp)
	Duel.SetTargetCard(g)
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		aux.EraseFromBurningZone(Group.FromCards(tc))
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

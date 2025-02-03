--폐성(루인 고스텔라)-폭주의 오버플로
local s,id=GetID()
function s.initial_effect(c)
	local e1=aux.AddEquipProcedure(c,nil,nil,nil,s.cost1,s.tar1,s.op1)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	local e2=MakeEff(c,"E")
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"STo")
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
end
function s.tfil1(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
function s.cfun1(sg,tp,exg,dg)
	local a=0
	for c in aux.Next(sg) do
		if dg:IsContains(c) then a=a+1 end
		for tc in aux.Next(c:GetEquipGroup()) do
			if dg:IsContains(tc) then a=a+1 end
		end
	end
	return #dg-a>=1
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ghost=Duel.GetPlayerEffect(tp,EFFECT_GHOSTELLAR)
	local g=Duel.GMGroup(s.tfil1,tp,"M","M",nil,e)
	if chk==0 then
		return ghost or Duel.CheckReleaseGroupCost(tp,aux.TRUE,1,true,s.cfun1,nil,g)
	end
	if ghost then
		Duel.Hint(HINT_CARD,0,ghost:GetHandler():GetCode())
		ghost:Reset()
		e:SetLabel(0)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local sg=Duel.SelectReleaseGroupCost(tp,aux.TRUE,1,1,true,s.cfun1,nil,g)
		Duel.Release(sg,REASON_COST)
		e:SetLabel(1)
	end
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:SetLabel(0)
		return Duel.IsPlayerCanDiscardDeck(tp,1)
	end
	Duel.SOI(0,CATEGORY_DECKDES,nil,0,tp,1)
	Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"D")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.GetLocCount(tp,"M")>0 then
		local g=Duel.GMGroup(aux.TRUE,tp,"D",0,nil)
		local dcount=Duel.GetFieldGroupCount(tp,LSTN("D"),0)
		local seq=-1
		local spcard=nil
		for tc in g:Iter() do
			if tc:GetSequence()>seq
				and tc:IsSetCard("고스텔라") and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				and tc:GetLevel()>=dcount-tc:GetSequence() then
				seq=tc:GetSequence()
				spcard=tc
			end
		end
		if spcard then
			Duel.ConfirmDecktop(tp,dcount-seq)
			Duel.DisableShuffleCheck()
			if spcard:IsLevel(1) then
				Duel.SpecialSummon(spcard,0,tp,tp,false,false,POS_FACEUP)
			else
				Duel.SpecialSummonStep(spcard,0,tp,tp,false,false,POS_FACEUP)
				Duel.DiscardDeck(tp,dcount-seq-1,REASON_EFFECT)
				Duel.SpecialSummonComplete()
			end
		else
			Duel.ConfirmDecktop(tp,8)
			Duel.ShuffleDeck(tp)
		end
	end
	if e:GetLabel()~=0 then
		local e1=MakeEff(c,"F")
		e1:SetCode(EFFECT_GHOSTELLAR)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTR(1,0)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.val2(e,c)
	return math.ceil(c:GetOriginalLevel()/2)
end
function s.tfil3(c,e,tp)
	return c:IsSetCard("고스텔라") and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("G") and chkc:IsControler(tp) and s.tfil3(chkc,e,tp)
	end
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0 and Duel.IETarget(s.tfil3,tp,"G",0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.STarget(tp,s.tfil3,tp,"G",0,1,1,nil,e,tp)
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
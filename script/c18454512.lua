--저항할 수 없는 압도적인 화력
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_DRAW)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
end
s.listed_names={18454503}
function s.tfil1(c,e,tp)
	return c:IsCode(18454503) and ((Duel.GetLocCount(tp,"M")>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		or c:IsAbleToRemove())
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("G") and chkc:IsControler(tp) and s.tfil1(chkc,e,tp)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil1,tp,"G",0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.STarget(tp,s.tfil1,tp,"G",0,1,1,nil,e,tp)
	Duel.SOI(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,"D")
	Duel.SPOI(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.op1(e,tp,ep,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local b1=Duel.GetLocCount(tp,"M")>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		local b2=tc:IsAbleToRemove()
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,0)},
			{b2,aux.Stringid(id,1)})
		local chk=0
		if op==1 then
			chk=Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		elseif op==2 then
			chk=Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
		if chk>0 then
			local g=Duel.GMGroup(aux.TRUE,tp,0,"O",nil)
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.BreakEffect()
				local sc=g:GetFirst()
				for sc in aux.Next(g) do
					local e1=MakeEff(c,"S")
					e1:SetCode(EFFECT_CANNOT_TRIGGER)
					e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SET_AVAILABLE)
					e1:SetDescription(3302)
					e1:SetReset(RESETS_STANDARD_PHASE_END)
					sc:RegisterEffect(e1)
				end
				if Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
					Duel.BreakEffect()
					Duel.Draw(tp,1,REASON_EFFECT)
				end
			end
		end
	end
end
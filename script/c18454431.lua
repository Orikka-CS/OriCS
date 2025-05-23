--그대는 천진난만한 밤의 희망
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FC","D")
	e2:SetCode(EVENT_STARTUP)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCL(1,{id,1},EFFECT_COUNT_CODE_DUEL)
	WriteEff(e2,2,"O")
	c:RegisterEffect(e2)
end
function s.tfil1(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0 and Duel.IEMCard(s.tfil1,tp,"D",0,1,nil,e,tp)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"D")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocCount(tp,"M")>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:Code()==18454431 then
		local mt=_G["c18454431"]
		local ct=0
		while true do
			if not mt.eff_ct[c][ct] then
				break
			end
			mt.eff_ct[c][ct]:Reset()
			ct=ct+1
		end
		mt.eff_ct[c]=nil
		c:Recreate(18454451)
		local nmt=_G["c18454451"]
		if nmt==nil or nmt.initial_effect==nil then
			local token=Duel.CreateToken(tp,18454451)
		end
		c:SetStatus(STATUS_INITIALIZING,true)
		nmt=_G["c18454451"]
		nmt.initial_effect(c)
		c:SetStatus(STATUS_INITIALIZING,false)
		c:CancelToGrave()
		Duel.ChangePosition(c,POS_FACEDOWN)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IEMCard(Card.IsCode,tp,"D",0,2,nil,18454431) then
		Duel.Win(1-tp,0x0)
	end
end
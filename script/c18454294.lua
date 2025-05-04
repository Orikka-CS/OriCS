--µµÆÄ¹Î ±âÆøÁ¦
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
end
function s.cfil1(c)
	return c:IsSetCard("µµÆÄ¹Î") and c:IsAbleToGraveAsCost()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.cfil1,tp,"HO",0,1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.cfil1,tp,"HO",0,1,1,c)
	local tc=g:GetFirst()
	if tc:IsCode(id) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tfil1(c,e,tp)
	return c:IsSetCard("µµÆÄ¹Î") and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil,e,tp) and Duel.GetLocCount(tp,"M")>0
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"D")
end
function s.ofun1(g,chk)
	return #g==1 or (chk and #g==4 and s.oval1(g)==2)
end
function s.oval1(g)
	local val=0
	local code={}
	local tc=g:GetFirst()
	while tc do
		local tcode=tc:GetCode()
		if not code[tcode] then
			code[tcode]=0
		elseif code[tcode]==0 then
			code[tcode]=1
			val=val+1
		end
		tc=g:GetNext()
	end
	return val
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GMGroup(s.tfil1,tp,"D",0,nil,e,tp)
	if #g>0 and Duel.GetLocCount(tp,"M")>0 then
		local b=e:GetLabel()==1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocCount(tp,"M")>3
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:SelectSubGroup(tp,s.ofun1,false,1,4,b)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
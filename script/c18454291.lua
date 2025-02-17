--µµÆÄ¹Î Å½´ÐÀÚ
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"STo")
	e1:SetCode(EVENT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetCL(1,id)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","M")
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsReason(REASON_DRAW)
end
function s.cfil1(c,e,tp)
	local ec=e:GetHandler()
	return c:IsSetCard("µµÆÄ¹Î") and not c:IsPublic()
		and (c:IsAbleToGrave()
			or (ec:IsCode(id) and c:IsCode(id) and Duel.GetLocCount(tp,"M")>1
				and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.cfil1,tp,"H",0,1,c,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SMCard(tp,s.cfil1,tp,"H",0,1,1,c,e,tp)
	local tc=g:GetFirst()
	tc:CreateEffectRelation(e)
	e:SetLabelObject(tc)
	g:AddCard(c)
	if g:IsExists(Card.IsCode,2,nil,id) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	Duel.ConfirmCards(1-tp,g)
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
	local tc=e:GetLabelObject()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local b1=tc:IsAbleToGrave()
		local b2=e:GetLabel()==1 and Duel.GetLocCount(tp,"M")>1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
		if op==1 then
			if Duel.SendtoGrave(tc,REASON_EFFECT)>0 then
				Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
			end
		elseif op==2 then
			local g=Group.FromCards(c,tc)
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.cfil2(c)
	return c:IsSetCard("µµÆÄ¹Î") and c:IsAbleToGraveAsCost()
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.cfil2,tp,"O",0,1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.cfil2,tp,"O",0,1,1,c)
	g:AddCard(c)
	if g:IsExists(Card.IsCode,2,nil,id) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tfil2(c,e,tp)
	return c:IsSetCard("µµÆÄ¹Î") and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil2,tp,"D",0,1,nil,e,tp) and Duel.GetLocCount(tp,"M")>0
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"D")
end
function s.ofun2(g,chk)
	return #g==1 or (chk and #g==4 and s.oval2(g)==2)
end
function s.oval2(g)
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
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GMGroup(s.tfil2,tp,"D",0,nil,e,tp)
	if #g>0 and Duel.GetLocCount(tp,"M")>0 then
		local b=e:GetLabel()==1 and Duel.GetLocCount(tp,"M")>3
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:SelectSubGroup(tp,s.ofun2,false,1,4,b)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
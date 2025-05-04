--µµÆÄ¹Î ÀüÆÄÀÚ
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"I","H")
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetCL(1,id)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","M")
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
end
function s.cfil11(c,e,tp)
	local ec=e:GetHandler()
	return c:IsSetCard("µµÆÄ¹Î") and not c:IsPublic()
		and ((c:IsAbleToGrave() and ec:IsAbleToGrave())
			or (ec:IsCode(id) and c:IsCode(id) and Duel.GetLocCount(tp,"M")>3
				and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
				and ec:IsCanBeSpecialSummoned(e,0,tp,false,false)
				and Duel.IEMCard(s.cfil12,tp,"D",0,1,nil,e,tp)))
end
function s.cfil12(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard("µµÆÄ¹Î") and not c:IsCode(id)
		and Duel.IEMCard(s.cfil13,tp,"D",0,1,c,e,tp,c:GetCode())
end
function s.cfil13(c,e,tp,code)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCode(code)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.cfil11,tp,"H",0,1,c,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SMCard(tp,s.cfil11,tp,"H",0,1,1,c,e,tp)
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
function s.tfil1(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard("µµÆÄ¹Î") and not c:IsCode(id)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil,e,tp) and Duel.GetLocCount(tp,"M")>0
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"D")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local b1=c:IsAbleToGrave() and tc:IsAbleToGrave()
		local b2=e:GetLabel()==1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and Duel.GetLocCount(tp,"M")>3 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IEMCard(s.cfil12,tp,"D",0,1,nil,e,tp)
		local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
		if op==1 then
			local g=Group.FromCards(c,tc)
			if Duel.SendtoGrave(g,REASON_EFFECT)>0 and Duel.GetLocCount(tp,"M")>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil,e,tp)
				if #sg>0 then
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		elseif op==2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g1=Duel.SMCard(tp,s.cfil12,tp,"D",0,1,1,nil,e,tp)
			local sc=g1:GetFirst()
			local g2=Duel.SMCard(tp,s.cfil13,tp,"D",0,1,1,g1,e,tp,sc:GetCode())
			g1:Merge(g2)
			g1:Merge(Group.FromCards(c,tc))
			Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
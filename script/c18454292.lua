--µµÆÄ¹Î º¹Á¦ÀÚ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,"µµÆÄ¹Î"),2)
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetCL(1,id)
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
end
function s.vfil1(c,g)
	return c:IsSetCard("µµÆÄ¹Î") and g:IsExists(Card.IsCode,1,c,c:GetCode())
end
function s.val1(e,c)
	local g=c:GetMaterial()
	e:SetLabel(0)
	if #g==2 and g:IsExists(s.vfil1,1,nil,g) then
		e:SetLabel(1)
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.tfil2(c)
	return c:IsSetCard("µµÆÄ¹Î") and c:IsAbleToHand()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GMGroup(Card.IsAbleToGrave,tp,"H",0,nil)
	local g2=Duel.GMGroup(s.tfil2,tp,"D",0,nil)
	if chk==0 then
		return #g1>1 and #g2>0
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
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
	local g1=Duel.GMGroup(Card.IsAbleToGrave,tp,"H",0,nil)
	local g2=Duel.GMGroup(s.tfil2,tp,"D",0,nil)
	if #g1>1 and #g2>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg1=g1:Select(tp,2,2,nil)
		if Duel.SendtoGrave(sg1,REASON_EFFECT)>0 then
			local b=e:GetLabelObject():GetLabel()==1
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg2=g2:SelectSubGroup(tp,s.ofun2,false,1,4,b)
			Duel.SendtoHand(sg2,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg2)
		end
	end
end
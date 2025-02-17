--µµÆÄ¹Î Áßµ¶ÀÚ
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"STo")
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCL(1,id)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.cfil1(c)
	return c:IsFaceup() and c:IsCode(id)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToGraveAsCost() or Duel.IEMCard(s.cfil1,tp,"O",0,1,c)
	end
	if not Duel.IEMCard(s.cfil1,tp,"O",0,1,c) then
		Duel.SendtoGrave(c,REASON_COST)
	end
end
function s.tfil1(c)
	return c:IsSetCard("µµÆÄ¹Î") and c:IsAbleToHand() and not c:IsCode(id)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
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
	local c=e:GetHandler()
	local g=Duel.GMGroup(s.tfil1,tp,"D",0,nil)
	if #g>0 then
		local b=Duel.IEMCard(s.cfil1,tp,"O",0,1,c)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:SelectSubGroup(tp,s.ofun1,false,1,4,b)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
--이터널 툰드라
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"I","S")
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetCL(1,id)
	WriteEff(e3,3,"NCTO")
	c:RegisterEffect(e3)
end
s.listed_names={15259703}
function s.tfil1(c)
	return c:IsType(TYPE_TOON)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"H",0,1,nil) and Duel.IsPlayerCanDraw(tp,2)
	end
	Duel.SOI(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISARD)
	local g=Duel.SMCard(tp,s.tfil1,tp,"H",0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)>0 then
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
function s.nfil3(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IEMCard(s.nfil3,tp,"O",0,1,nil)
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToGraveAsCost()
	end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.tfil3(c)
	return c:IsSetCard(0x1062) and c:IsAbleToHand() and not c:IsCode(id) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil3,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil3,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
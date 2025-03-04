--퍼스트쿼터 드레이크
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e1:SetCondition(s.con1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"I","H")
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetCL(1,id)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
end
function s.con1(e)
	local c=e:GetHandler()
	return c:IsLoc("HOG")
end
function s.cfil2(c)
	return (c:IsAttack(2500) or c:IsDefense(2500)) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and not c:IsCode(id)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.cfil2,tp,"D",0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.cfil2,tp,"D",0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.GetLocCount(tp,"M")>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local b2=c:IsAbleToGrave()
	if chk==0 then
		return b1 or b2
	end
	Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SPOI(0,CATEGORY_TOGRAVE,c,1,0,0)
end
function s.ofil2(c)
	return c:IsCode(71490127) and c:IsAbleToHand()
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then
		return
	end
	local b1=Duel.GetLocCount(tp,"M")>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local b2=c:IsAbleToGrave()
	local res=nil
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b1,aux.Stringid(id,1)})
	if op==1 then
		res=Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	elseif op==2 then
		res=Duel.SendtoGrave(c,REASON_EFFECT)
	end
	if res and res>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SMCard(tp,s.ofil2,tp,"DG",0,0,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
--춘향신화, 그 찬란한 복수의 완성
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSquareProcedure(c)
	local e1=MakeEff(c,"I","H")
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S","M")
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"S","MG")
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetValue(18454503)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"STo")
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCL(1,id)
	WriteEff(e4,4,"O")
	c:RegisterEffect(e4)
end
s.square_mana={ATTRIBUTE_FIRE,ATTRIBUTE_FIRE,ATTRIBUTE_FIRE,ATTRIBUTE_FIRE,ATTRIBUTE_FIRE,ATTRIBUTE_FIRE,ATTRIBUTE_FIRE}
s.custom_type=CUSTOMTYPE_SQUARE
s.listed_names={18454503}
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsDiscardable()
	end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.tfil1(c)
	return c:ListsCode(18454503) and c:IsAbleToHand() and c:IsType(TYPE_SPELL)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.val2(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoGrave(c,REASON_EFFECT+REASON_RETURN)
	end
end
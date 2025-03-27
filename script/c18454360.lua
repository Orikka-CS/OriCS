--Ω ¿Ã»Ò «œæﬂ≈◊∫∏øÏ
local s,id=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,nil,3,5,s.pfil1,aux.Stringid(id,0),5,s.pop1)
	c:EnableReviveLimit()
	local e1=MakeEff(c,"S","M")
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"STo")
	e4:SetCode(EVENT_BATTLED)
	e4:SetCategory(CATEGORY_TOGRAVE)
	WriteEff(e4,4,"TO")
	c:RegisterEffect(e4)
end
function s.pfil1(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard("Ω ¿Ã»Ò") and not c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,id)
end
function s.pop1(e,tp,chk)
	if chk==0 then
		return Duel.GetFlagEffect(tp,id)==0
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end
function s.vfil1(c)
	return c:IsSetCard("Ω ¿Ã»Ò") and c:GetAttack()>=0
end
function s.val1(e)
	local ec=e:GetHandler()
	local g=ec:GetOverlayGroup():Filter(s.vfil1,nil)
	return g:GetSum(Card.GetAttack)
end
function s.vfil2(c)
	return c:IsSetCard("Ω ¿Ã»Ò") and c:GetDefense()>=0
end
function s.val2(e)
	local ec=e:GetHandler()
	local g=ec:GetOverlayGroup():Filter(s.vfil2,nil)
	return g:GetSum(Card.GetDefense)
end
function s.tfil4(c,tp)
	return ((c:IsControler(tp) and c:IsSetCard("Ω ¿Ã»Ò")) or c:IsControler(1-tp)) and c:IsAbleToGrave()
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil4,tp,"D","O",1,nil,tp)
	end
	Duel.SOI(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,"DO")
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.tfil4,tp,"D","O",1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		if tc:IsOnField() then
			Duel.HintSelection(g)
		end
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
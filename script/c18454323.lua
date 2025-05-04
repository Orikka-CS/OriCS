--F☆G★D(파이어 걸 딜라이트)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddDelightProcedure(c,nil,5,5)
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FTo","M")
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCategory(CATEGORY_DAMAGE)
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
end
s.custom_type=CUSTOMTYPE_DELIGHT
function s.val1(e,se,sp,st)
	return st&SUMMON_TYPE_DELIGHT==SUMMON_TYPE_DELIGHT
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return #eg==1 and tc:IsPreviousPosition(POS_FACEUP) and tc:IsPreviousLocation(LSTN("M"))
		and tc:GetTextAttack()>0
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then
		e:SetLabel(tc:GetTextAttack())
		return true
	end
	Duel.SOI(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,e:GetLabel(),REASON_EFFECT)
end
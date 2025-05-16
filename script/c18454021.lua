--마과학요정 미즈하
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"I","HSG")
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCL(1,id)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"FTo","M")
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetCL(1,{id,1})
	WriteEff(e3,3,"N")
	WriteEff(e3,2,"TO")
	c:RegisterEffect(e3)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLoc("HG") or c:GetType()&(TYPE_SPELL+TYPE_CONTINUOUS)==(TYPE_SPELL+TYPE_CONTINUOUS)
end
function s.cfil1(c,tp)
	return ((c:IsOnField() and c:IsType(TYPE_SPELL+TYPE_TRAP)) or (c:IsSetCard("마과학") and c:IsLoc("G")))
		and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.cfil1,tp,"OG",0,1,c,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SMCard(tp,s.cfil1,tp,"OG",0,1,1,c,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocCount(tp,"S")>0
	end
	Duel.SOI(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocCount(tp,"S")>0 then
		local e1=MakeEff(c,"S","S")
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SINGLE_RANGE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
		Duel.MoveToField(c,tp,tp,LSTN("S"),POS_FACEUP,true)
		Duel.Recover(tp,1000,REASON_EFFECT)
	end
end
function s.nfil3(c)
	return c:IsPreviousLocation(LSTN("OG"))
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.nfil3,1,nil)
end
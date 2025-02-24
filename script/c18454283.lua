--방패의 비마술
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"F")
	e1:SetCode(EFFECT_CANNOT_INACTIVATE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(s.oval11)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_DISEFFECT)
	Duel.RegisterEffect(e2,tp)
	local e3=MakeEff(c,"F")
	e3:SetCode(EFFECT_CANNOT_DISABLE)
	e3:SetTR("O",0)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetTarget(s.otar13)
	Duel.RegisterEffect(e3,tp)
end
function s.oval11(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	local tc=te:GetHandler()
	return p==tp and tc:IsSetCard("방패")
end
function s.otar13(e,c)
	return c:IsSetCard("방패")
end
function s.tfil2(c,e,tp)
	return (c:IsSSetable() or (Duel.GetLocCount(tp,"M")>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)))
		and c:IsFaceup() and c:IsSetCard("방패")
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("GR") and chkc:IsControler(tp) and s.tfil2(chkc,e,tp)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil2,tp,"GR",0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.STarget(tp,s.tfil2,tp,"GR",0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(0)
	end
	if tc:IsLoc("G") then
		Duel.SOI(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsSSetable() then
			Duel.SSet(tp,tc)
		else
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		end
	end
end
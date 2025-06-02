--sparkle.exe: Error's cute when chased by fun
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FTo","G")
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
end
function s.tfil11(c,e,tp)
	return c:IsSetCard("sparkle.exe") and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tfil12(c,e,tp)
	return c:IsSetCard("sparkle.exe") and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("G") and chkc:IsControler(tp) and s.tfil12(chkc,e,tp)
	end
	local b1=Duel.IEMCard(s.tfil11,tp,"H",0,1,nil,e,tp)
	local b2=Duel.IETarget(s.tfil12,tp,"G",0,1,nil,e,tp)
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0 and (b1 or b2)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.STarget(tp,s.tfil12,tp,"G",0,0,1,nil,e,tp)
	if #g>0 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetProperty(0)
		Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,"H")
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocCount(tp,"M")<=0 then
		return
	end
	local tc=Duel.GetFirstTarget()
	if tc then
		if tc:IsRelateToEffect(e) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SMCard(tp,s.tfil1,tp,"H",0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	if ev<=2 then
		return false
	end
	local p0=Duel.GetChainInfo(ev-2,CHAININFO_TRIGGERING_PLAYER)
	local p1=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_PLAYER)
	return p0==tp and p1~=tp and rp==tp
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToHand() or c:IsSSetable()
	end
	Duel.SPOI(0,CATEGORY_TOHAND,c,1,0,0)
	Duel.SOI(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		aux.ToHandOrElse(c,tp,Card.IsSSetable,
		function(c)
			Duel.SSet(tp,c)
		end)
	end
end
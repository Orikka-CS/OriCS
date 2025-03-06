--[ ChaoticWing ]
local s,id=GetID()
function s.initial_effect(c)

	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xcd70),4,2,s.ovfilter,aux.Stringid(id,3),2,s.xyzop)

	local e99=MakeEff(c,"F","MG")
	e99:SetDescription(aux.Stringid(id,2))
	e99:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e99:SetTargetRange(LOCATION_HAND,0)
	c:RegisterEffect(e99)

	local e0=MakeEff(c,"FTo","G")
	e0:SetD(id,0)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_LEAVE_FIELD)
	e0:SetCL(1,{id,1})
	WriteEff(e0,0,"NTO")
	c:RegisterEffect(e0)

	local e1=MakeEff(c,"Qo","M")
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetCL(1,id)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
end

function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,CARD_TORNADO_DRAGON)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
	return true
end

function s.con0fil(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT)
end
function s.con0(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsSpellEffect()
		and eg:IsExists(s.con0fil,1,nil)
end
function s.tar0(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
end
function s.op0fil(c,xc,tp)
	return c:IsCanBeXyzMaterial(xc,tp,REASON_EFFECT)
end
function s.op0(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		if Duel.IsExistingMatchingCard(s.op0fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,c,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
			local g=Duel.SelectMatchingCard(tp,s.op0fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,c,tp)
			if #g==0 then return end
			Duel.HintSelection(g,true)
			Duel.BreakEffect()
			Duel.Overlay(c,g)
		end
	end
end

function s.tar1fil(c,e,tp)
	return (c:IsCode(CARD_TORNADO_DRAGON) or c:IsSetCard(0xcd70)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.tar1fil,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.op1fil(c,class)
	return c:IsSpell() and class.listed_names and c:IsCode(table.unpack(class.listed_names)) and c:IsAbleToHand()
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tar1fil),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.op1fil),tp,LOCATION_GRAVE,0,nil,tc)
		if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=tg:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end

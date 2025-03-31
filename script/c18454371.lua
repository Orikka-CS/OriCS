--어차피 할거 당장 저질러(Sicilian Defense: Open, Najdorf Variation)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)	
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCost(s.cost1)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetValue(function(e,c) e:SetLabel(1) end)
	e3:SetCondition(function(e)
		local tp=e:GetHandlerPlayer()
		return Duel.CheckLPCost(tp,1000)
	end)
	c:RegisterEffect(e3)
	e1:SetLabelObject(e3)
	e2:SetLabelObject(e3)
end
s.listed_series={0xc00}
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:GetLabelObject():SetLabel(0)
		return true
	end
	if e:GetLabelObject():GetLabel()>0 then
		e:GetLabelObject():SetLabel(0)
		Duel.PayLPCost(tp,1000)
	end
end
function s.tfil1(c)
	return c:IsSetCard(0xc00) and c:IsType(TYPE_MONSTER+TYPE_SPELL) and c:IsAbleToGrave()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil1,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.ofun1(g,e,tp)
	return g:GetClassCount(s.oval1)==#g
end
function s.oval1(c)
	return c:GetType()&0x7
end
function s.ofil1(c,typ)
	return c:IsSetCard(0xc00) and c:IsType(TYPE_MONSTER+TYPE_SPELL) and c:IsAbleToHand()
		and typ&(c:GetType()&0x7)==0
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tfil1,tp,LOCATION_DECK,0,nil)
	if #g==0 then
		return
	end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,2,s.ofun1,1,tp,HINTMSG_ATOHAND)
	if sg then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		if #sg==1 then
			local tc=sg:GetFirst()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local dg=Duel.SelectMatchingCard(tp,s.ofil1,tp,LOCATION_GRAVE,0,0,1,nil,tc:GetType()&0x7)
			if #dg>0 then
				Duel.BreakEffect()
				Duel.HintSelection(dg)
				Duel.SendtoHand(dg,nil,REASON_EFFECT)
			end
		end
	end
end
function s.tfil2(c)
	return c:IsFaceup() and not c:IsCode(id+1)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tfil2(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tfil2,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.tfil2,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.ofil21(c,e,tp,att)
	return c:IsSetCard(0xc00) and c:IsCanBeFusionMaterial()
		and c:IsAbleToGrave()
		and not c:IsImmuneToEffect(e)
		and Duel.IsExistingMatchingCard(s.ofil22,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,att)
end
function s.ofil22(c,e,tp,mc,att)
	if Duel.GetLocationCountFromEx(tp,tp,mc,c)<=0 then
		return false
	end
	local mustg=aux.GetMustBeMaterialGroup(tp,nil,tp,c,nil,REASON_FUSION)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xc00) and c.red_thread_att&att~=0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and (#mustg==0 or (#mustg==1 and mustg:IsContains(mc)))
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if s.tfil2(tc) and tc:IsRelateToEffect(e) then
		local att=tc:GetAttribute()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(id+1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		tc:RegisterEffect(e2)
		if tc:IsCode(id+1) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local mg=Duel.SelectMatchingCard(tp,s.ofil21,tp,LOCATION_HAND+LOCATION_MZONE,0,0,1,nil,e,tp,att)
			if #mg>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local mc=mg:GetFirst()
				local sg=Duel.SelectMatchingCard(tp,s.ofil22,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mc,att)
				local sc=sg:GetFirst()
				sc:SetMaterial(mg)
				Duel.SendtoGrave(mg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				Duel.BreakEffect()
				Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
				sc:CompleteProcedure()
			end
		end
	end
end
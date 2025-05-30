--붉은 실뭉치
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0xc00)
		,nil,s.pg1,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.tar1)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)	
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCost(s.cost1)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
s.listed_series={0xc00}
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if not Duel.CheckPhaseActivity() then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	if chk==0 then
		return true
	end
end
function s.pgfil1(c)
	return c:IsAbleToGrave() and c:IsSetCard(0xc00)
end
function s.pg1(e,tp,mg)
	if e:GetLabel()==1 then
		local sg=Duel.GetMatchingGroup(s.pgfil1,tp,LOCATION_DECK,0,nil)
		if #sg>0 then
			return sg,s.pgfun1
		end
	end
	return nil
end
function s.pgfun1(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	if e:GetLabel()==1 then
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end
function s.tfil2(c)
	return c:IsFaceup() and (c:IsAttackAbove(1) or c:IsDefenseAbove(1))
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
	if e:GetLabel()==1 then
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
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
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		tc:RegisterEffect(e3)
		if tc:IsAttack(0) and tc:IsDefense(0) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local loc=LOCATION_HAND+LOCATION_MZONE
			if e:GetLabel()==1 then
				loc=LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE
			end
			local mg=Duel.SelectMatchingCard(tp,s.ofil21,tp,loc,0,0,1,nil,e,tp,att)
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
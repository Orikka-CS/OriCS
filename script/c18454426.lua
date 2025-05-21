--청록 실♩카르마 스프라우트
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(s.con4)
	c:RegisterEffect(e4)
	if s.global_check==nil then
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(ge2,0)
		local ge3=ge1:Clone()
		ge3:SetCode(EVENT_MSET)
		Duel.RegisterEffect(ge3,0)
	end
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if not re or (not re:IsHasType(EFFECT_TYPE_ACTIONS)
			and (re:GetHandler()~=tc or tc:IsType(TYPE_SPSUMMON))) then
			Duel.RegisterFlagEffect(rp,id,RESET_PHASE+PHASE_END,0,1)
		end
		tc=eg:GetNext()
	end
end
function s.cfil1(c,tp)
	return c:IsAbleToRemoveAsCost() and c:IsHasEffect(18454430,tp)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cfil1,tp,LOCATION_GRAVE,0,nil,tp)
	g:AddCard(c)
	if chk==0 then
		return Duel.GetFlagEffect(tp,id)==0 and #g>0 and Duel.GetFlagEffect(tp,id-10000)==0
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.ctar11)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_MSET)
	Duel.RegisterEffect(e3,tp)
	local sc=nil
	if #g==1 then
		sc=g:GetFirst()
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:Select(tp,1,1,nil)
		sc=sg:GetFirst()
	end
	if sc==c then
		Duel.SendtoGrave(c,REASON_COST)
	else
		Duel.HintSelection(Group.FromCards(sc))
		local se=sc:IsHasEffect(18454430)
		se:UseCountLimit(tp)
		Duel.Remove(sc,POS_FACEUP,REASON_COST)
	end
	Duel.RegisterFlagEffect(tp,id-10000,RESET_CHAIN,0,0)
end
function s.ctar11(e,c,sump,sumtype,sumpos,targetp,se)
	return not se or (not se:IsHasType(EFFECT_TYPE_ACTIONS)
		and (se:GetHandler()~=c or c:IsType(TYPE_SPSUMMON)))
end
function s.tfil1(c,e,tp)
	return c:IsLevelBelow(4) and c:IsType(TYPE_TUNER) and (c:IsAbleToHand()
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tfil1(chkc,e,tp)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tfil1,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.tfil1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,LOCATION_EXTRA,tp)
end
function s.ofil1(c,e,tp,tc)
	return Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and c:IsLevel(tc:GetLevel()+8) and c:IsType(TYPE_SYNCHRO)
		and (c:IsRace(RACE_FAIRY|RACE_DRAGON) or c:IsAttribute(ATTRIBUTE_WIND|ATTRIBUTE_WATER))
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		aux.ToHandOrElse(tc,tp,
			function()
				return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
					and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			end,
			function()
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e2)
				Duel.SpecialSummonComplete()
			end,
			aux.Stringid(id,0)
		)
		if tc:IsLocation(LOCATION_HAND|LOCATION_MZONE) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.ofil1,tp,LOCATION_EXTRA,0,0,1,nil,e,tp,tc)
			local sc=g:GetFirst()
			if sc then
				Duel.BreakEffect()
				if Duel.SendtoGrave(tc,REASON_EFFECT)>0 then
					Duel.SpecialSummon(g,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
					sc:CompleteProcedure()
				end
			end
		end
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_EFFECT~=0
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFlagEffect(tp,id-10000)==0
	end
	Duel.RegisterFlagEffect(tp,id-10000,RESET_CHAIN,0,0)
end
function s.tfil2(c)
	return c:IsSetCard(0xc08) and not c:IsCode(id) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil2,tp,LOCATION_DECK,0,1,nil)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tfil2,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	aux.ToHandOrElse(tc,tp)
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and re:IsHasType(EFFECT_TYPE_ACTIONS)
end
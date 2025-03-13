--HRUM(헤븐리 랭크 업 매직)-세레나데 포스
local s,id=GetID()
function s.initial_effect(c)
	--필드의 효과 몬스터 1장을 골라. 그 효과를 턴 종료시까지 무효로 하고, 그 몬스터의 공격력만큼만 자신의 LP를 회복한다.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--그 2장 이상의 몬스터의 랭크의 합계와 같은 랭크를 가지는 엑시즈 몬스터 1장을 엑시즈 소환으로 취급하여 엑스트라 덱에서 특수 소환하고, 대상 몬스터를 그 엑시즈 소재로 한다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(TIMING_DRAW_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(aux.AND(s.condition,aux.exccon))
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptarget)
	e2:SetOperation(s.spactivate)
	c:RegisterEffect(e2)
end
s.listed_series={0xc22}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
function s.filter(c)
	return c:IsFaceup() and not c:IsDisabled() and c:IsType(TYPE_EFFECT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local exc=nil
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then exc=e:GetHandler() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,exc)
	if #g>0 then
		local tc=g:GetFirst()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		Duel.AdjustInstantly(tc)
		local atk=tc:GetAttack()
		if not tc:IsImmuneToEffect(e1) and not tc:IsImmuneToEffect(e2) and atk>0 then
			Duel.Recover(tp,atk,REASON_EFFECT)
		end
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() or (Duel.IsTurnPlayer(1-tp) and Duel.IsBattlePhase())
end
function s.tgfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0xc22) and c:IsFaceup()
		and c:IsCanBeXyzMaterial(nil,tp,REASON_EFFECT) and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg:GetSum(Card.GetRank))
end
function s.spfilter(c,e,tp,rk)
	return c:IsType(TYPE_XYZ) and c:IsRank(rk) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and (not c.rum_limit or g:IsExists(function(mc) return c.rum_limit(mc,e) end,1,nil))
end
function s.sptarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,#g,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,#g,s.rescon,1,tp,HINTMSG_XMATERIAL,s.rescon)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	local gyg=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #gyg>0 then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,gyg,#gyg,tp,0)
	end
end
function s.spactivate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	local futg=tg:Filter(Card.IsFaceup,nil)
	if #futg<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,futg:GetSum(Card.GetRank)):GetFirst()
	if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()
		tg=tg:Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
		if #tg==0 then return end
		Duel.Overlay(sc,tg)
	end
end
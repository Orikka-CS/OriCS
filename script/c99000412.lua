--카구라노 카미시로 칸나즈키
local s,id=GetID()
function s.initial_effect(c)
	--order summon
	aux.AddOrderProcedure(c,"R",nil,s.ordfil1,aux.FilterBoolFunction(Card.IsSummonType,SUMMON_TYPE_SPECIAL))
	c:EnableReviveLimit()
	--자신은 덱에서 2장 드로우하고, 그 후의 자신 드로우 페이즈는 2회 스킵된다.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	--패에서 레벨 4 이하의 몬스터 1장을 특수 소환한다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.ordfil1(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	--상대는 패를 1장 이 카드의 컨트롤러에게 건네고 이 효과를 무효로 할 수 있다.
	local hg=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if #hg>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,3))
		local sg=hg:Select(1-tp,1,1,nil)
		Duel.SendtoHand(sg,tp,REASON_EFFECT)
		if Duel.IsChainDisablable(0) then
			Duel.NegateEffect(0)
			return
		end
	end
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Draw(p,2,REASON_EFFECT)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END,5)
	Duel.RegisterEffect(e1,tp)
end
function s.cfilter(c,e,tp)
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST|REASON_DISCARD,nil,e,tp)
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	if c:IsAttackPos() then
		Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,tp,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsRelateToEffect(e) and c:IsAttackPos() then
		Duel.BreakEffect()
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
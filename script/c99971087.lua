--블록체인 헬릭스
--Blockchain Helix
local s,id=GetID()
s.toss_coin=true
--Duel.LoadScript("blockchain.lua")
local B=Blockchain
function s.initial_effect(c)
	B.Init(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COIN|CATEGORY_DRAW|CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x6d72}
function s.costfilter(c,e,tp)
	return B.IsSetCard(c) and c:IsMonster() and B.CanRelease(c,e,tp,REASON_COST)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,e,tp)
	B.Release(g,REASON_COST,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) or Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 end
	B.Track(e,tp)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,2,1-tp,LOCATION_ONFIELD)
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and B.IsSetCard(c) and c:IsMonster()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp)
	local ctx=B.Context(e)
	if B.Toss(e,tp)==COIN_HEADS then
		Duel.Draw(tp,2,REASON_EFFECT)
		if ctx.previous_effect and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		--Choose before negation. A card may lose its own destruction immunity
		--when its effects are negated, so IsDestructable is not a prefilter.
		local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		if #g==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,1,math.min(2,#g),nil)
		if ctx.responded then
			for tc in aux.Next(sg) do
				if tc:IsFaceup() then tc:NegateEffects(e:GetHandler()) end
			end
			Duel.AdjustInstantly()
		end
		Duel.Destroy(sg,REASON_EFFECT)
	end
end

--말렉스카브 벤젠스
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.con0)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
end

--activate
function s.con0filter(c)
	return c:IsFaceup() and c:IsContinuousTrap() and c:IsTrapMonster()
end
function s.con0(e)
	return Duel.GetMatchingGroupCount(s.con0filter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)>0
end

--effect 1
function s.tg1filter(c,e,tp)
	return c:IsSetCard(0x5f20) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeEffectTarget(e)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tg1filter(chkc,e,tp) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.op1ctfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(0x5f20)
end
function s.op1filter(c)
	return c:IsFaceup() and c:IsNegatable()
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tg=Duel.GetTargetCards(e):GetFirst()
	if not tg or Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local ct=Duel.GetMatchingGroupCount(s.op1ctfilter,tp,LOCATION_MZONE,0,nil)
	local g=Duel.GetMatchingGroup(s.op1filter,tp,0,LOCATION_ONFIELD,nil)
	if ct>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.TRUE,1,tp,HINTMSG_NEGATE)
		for tc in sg:Iter() do
			tc:NegateEffects(e:GetHandler(),RESET_PHASE+PHASE_END,true)
		end
	end
end

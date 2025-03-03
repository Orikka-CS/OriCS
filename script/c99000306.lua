--�ǽ��� ���� �Ʊ׳�
local s,id=GetID()
function s.initial_effect(c)
	--���� ������ �ڽ��� �Ǵ� ���Ͱ� ��� �ʵ忡 ������ ���, �� ī��� �п��� Ư�� ��ȯ�� �� �ִ�.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--�ʵ��� ��� ������ ��Ʈ���� ���� ���ο��� �ǵ��ư���.
	Duel.EnableGlobalFlag(GLOBALFLAG_BRAINWASHING_CHECK)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_REMOVE_BRAINWASHING)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	c:RegisterEffect(e2)
	--����Ʈ�� ������ "�;��ǽ��� ������ �Ʊ׳�" 1���� Ư�� ��ȯ�Ѵ�.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={0xc16}
s.listed_names={99000307}
function s.spfilter1(c,tp)
	return c:GetOwner()==tp
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,0,LOCATION_MZONE,1,nil,tp)
end
function s.cfilter(c)
	return c:IsSetCard(0xc16) and c:IsNormalSpell() and c:IsAbleToDeckAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost()
		and aux.SelectUnselectGroup(g,e,tp,4,4,aux.dncheck,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,4,4,aux.dncheck,1,tp,HINTMSG_TODECK)
	sg:AddCard(e:GetHandler())
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.spfilter2(c,e,tp)
	return c:IsCode(99000307) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
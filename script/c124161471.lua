--브릿지버스터 리로드
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.tg2)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1filter(c,tp)
	return c:IsMonster() and c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con1filter,nil,tp)==1
end

function s.tg1filter(c,e,tp)
	return c:IsSetCard(0xf3e) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tg1filter(chkc,e,tp) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end

--effect 2
function s.tg2(e,c)
	return c:IsFaceup() and c:IsSetCard(0xf3e) and c:IsType(TYPE_XYZ)
end

function s.val2(e,re,c)
	if not re:IsActivated() then return false end
	if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		return not (g and g:IsContains(c))
	end
	return true
end
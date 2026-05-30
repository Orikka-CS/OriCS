--브릿지버스터 아르손
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.con2)
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c,e)
	return c:IsFaceup() and c:IsSetCard(0xf3e) and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e)
end

function s.tg1matfilter(c)
	return c:IsSetCard(0xf3e) and not c:IsType(TYPE_TOKEN)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg1filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil,e)
	local dg=Duel.GetMatchingGroup(s.tg1matfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 and #dg>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	local g=Duel.GetMatchingGroup(s.tg1matfilter,tp,LOCATION_DECK,0,nil)
	if tg and tg:IsFaceup() and #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_XMATERIAL)
		Duel.Overlay(tg,sg)
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsMonster() and c:IsControler(1-tp) and c:IsLocation(LOCATION_GRAVE)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,tp)>1
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end

function s.tg2filter(c,e)
	return c:IsCanBeEffectTarget(e)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,0,LOCATION_MZONE,nil,e)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DESTROY)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
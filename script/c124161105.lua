--독훼귀대륜
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TODECK)
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
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.tg2)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1ffilter(c)
	return c:IsSetCard(0xf26) and c:IsMonster() and c:IsAbleToDeck()
end

function s.tg1filter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayGroup():FilterCount(s.tg1ffilter,nil)>0
end

function s.tg1ofilter(c,e)
	return c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g1=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil,e)
	local g2=Duel.GetMatchingGroup(s.tg1ofilter,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return #g1>0 and #g2>0 end
	local sg1=aux.SelectUnselectGroup(g1,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
	local sg2=aux.SelectUnselectGroup(g2,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
	sg1:Merge(sg2)
	Duel.SetTargetCard(sg1)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,100)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg1,2,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	local tg1=tg:Filter(Card.IsControler,nil,tp):GetFirst():GetOverlayGroup():Filter(s.tg1ffilter,nil)
	local tg2=tg:Filter(Card.IsControler,nil,1-tp)
	if #tg1>0 and Duel.Damage(1-tp,tg1:GetSum(Card.GetDefense),REASON_EFFECT)>0 and #tg2>0 then
		Duel.BreakEffect()
		local tsg=aux.SelectUnselectGroup(tg1,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
		Duel.SendtoDeck(tsg+tg2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

--effect 2
function s.tg2(e,c)
	return c:IsFaceup() and c:IsSetCard(0xf26)
end
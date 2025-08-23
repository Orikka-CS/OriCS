--G.Rock 일룸
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCondition(s.con1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con2)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.con3)
	e3:SetCost(s.cost3)
	e3:SetTarget(s.tar3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return c:GetLevel()>=5 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,1,nil,0xfa6)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.cfil2(c)
	return c:IsAbleToGraveAsCost() and c:IsType(TYPE_XYZ) and c:IsRank(9)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfil2,tp,LOCATION_EXTRA,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfil2,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		rc:CancelToGrave()
		Duel.SendtoDeck(rc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST)
	end
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
function s.tfil3(c,e,tp,ec)
	return c:IsSetCard(0xfa6) and c:IsType(TYPE_MONSTER)
		and ((c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ec:IsAbleToDeck())
			or (ec:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsAbleToDeck()))
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingTarget(s.tfil3,tp,LOCATION_GRAVE,0,1,c,e,tp,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.tfil3,tp,LOCATION_GRAVE,0,1,1,c,e,tp,c)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.ofil3(c,e,tp,g)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:IsExists(Card.IsAbleToDeck,1,c)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local g=Group.FromCards(c,tc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:FilterSelect(tp,s.ofil3,1,1,nil,e,tp,g)
		if #sg==0 then
			return
		end
		local tg=g:Sub(sg)
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
			Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
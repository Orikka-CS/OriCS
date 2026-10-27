--언엔달 아우가 헬라
local s,id=GetID()
function s.initial_effect(c)
	--xyz
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),4,2)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetCost(Cost.DetachFromSelf(1,1,nil))
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1g1filter(c,e)
	return c:IsSetCard(0x3f20) and c:IsFaceup() and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
function s.tg1g2filter(c,e)
	return c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g1=Duel.GetMatchingGroup(s.tg1g1filter,tp,LOCATION_ONFIELD,0,nil,e)
	local g2=Duel.GetMatchingGroup(s.tg1g2filter,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return #g1>0 and #g2>0 end
	local sg1=aux.SelectUnselectGroup(g1,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_RTOHAND)
	local sg2=aux.SelectUnselectGroup(g2,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_RTOHAND)
	sg1:Merge(sg2)
	Duel.SetTargetCard(sg1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg1,2,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND)
end
function s.op1eqfilter(c,tp,mg)
	return c:IsCode(124162013) and c:CheckUniqueOnField(tp) and mg:IsExists(function(mc) return c:CheckEquipTarget(mc) end,1,nil)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 or Duel.SendtoHand(tg,nil,REASON_EFFECT)==0 then return end
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local g=Duel.GetMatchingGroup(s.op1eqfilter,tp,LOCATION_HAND,0,nil,tp,mg)
	if #mg>0 and #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_EQUIP):GetFirst()
		local hg=mg:Filter(function(c) return sg:CheckEquipTarget(c) end,nil)
		local hsg=aux.SelectUnselectGroup(hg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_EQUIP):GetFirst()
		Duel.Equip(tp,sg,hsg)
	end
end

--effect 2
function s.con2filter(c,tp)
	local re=c:GetReasonEffect()
	return c:IsSetCard(0x3f20) and c:IsReason(REASON_COST) and re and re:IsActivated() and c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,tp)>0
end
function s.tg2filter(c,e)
	return c:IsAbleToGrave() and c:IsCanBeEffectTarget(e)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,sg,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then Duel.SendtoGrave(tg,REASON_EFFECT) end
end

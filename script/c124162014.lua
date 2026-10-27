--언엔달 얼루어
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_CONTROL+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c,e,tp)
	return c:IsCode(124162013) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
		and (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or (c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5))
end
function s.tg1ctfilter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and s.tg1filter(chkc,e,tp) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,e,tp)
	local mg=Duel.GetMatchingGroup(s.tg1ctfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 and #mg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_RTOHAND)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,mg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND)
end
function s.op1eqfilter(c,tp,mc)
	return c:IsCode(124162013) and c:CheckUniqueOnField(tp) and c:CheckEquipTarget(mc)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if not tg or Duel.SendtoHand(tg,nil,REASON_EFFECT)==0 or not tg:IsLocation(LOCATION_HAND) then return end
	local mg=Duel.GetMatchingGroup(s.tg1ctfilter,tp,0,LOCATION_MZONE,nil)
	if #mg==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local msg=aux.SelectUnselectGroup(mg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONTROL):GetFirst()
	if Duel.GetControl(msg,tp)==0 then return end
	Duel.BreakEffect()
	local g=Duel.GetMatchingGroup(s.op1eqfilter,tp,LOCATION_HAND,0,nil,tp,msg)
	if #g>0 and msg:IsFaceup() and msg:IsControler(tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_EQUIP):GetFirst()
		Duel.Equip(tp,sg,msg)
	end
end

--effect 2
function s.tg2g1filter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetEquipGroup():IsExists(Card.IsCode,1,nil,124162013) and c:IsCanBeEffectTarget(e)
end
function s.tg2g2filter(c,e)
	return not c:IsType(TYPE_TOKEN) and c:IsCanBeEffectTarget(e)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g1=Duel.GetMatchingGroup(s.tg2g1filter,tp,LOCATION_MZONE,0,nil,e)
	local g2=Duel.GetMatchingGroup(s.tg2g2filter,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return #g1>0 and #g2>0 end
	local sg1=aux.SelectUnselectGroup(g1,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_FACEUP)
	local sg2=aux.SelectUnselectGroup(g2,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_XMATERIAL)
	e:SetLabelObject(sg1:GetFirst())
	sg1:Merge(sg2)
	Duel.SetTargetCard(sg1)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	local mc=e:GetLabelObject()
	if not mc or not tg:IsContains(mc) or not mc:IsFaceup() or not mc:IsType(TYPE_XYZ) or mc:IsImmuneToEffect(e) then return end
	tg:RemoveCard(mc)
	local g=tg:Filter(function(c) return not c:IsImmuneToEffect(e) end,nil)
	if #g>0 then Duel.Overlay(mc,g,true) end
end

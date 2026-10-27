--언엔달 클로 펜리르
local s,id=GetID()
function s.initial_effect(c)
	--xyz
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x3f20),4,2)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_EQUIP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con2)
	e2:SetCost(Cost.DetachFromSelf(1,1,nil))
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end

--effect 1
function s.con1filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3f20)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	local ct=Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_ONFIELD,0,c)
	return rp==1-tp and ct>0 and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)&LOCATION_ONFIELD>0
		and rc:IsOnField() and rc:IsRelateToEffect(re) and not rc:IsType(TYPE_TOKEN)
end
function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler())
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(sg,REASON_COST)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsType(TYPE_XYZ) and not c:IsImmuneToEffect(e)
		and rc:IsRelateToEffect(re) and rc:IsOnField() and not rc:IsImmuneToEffect(e) then
		rc:CancelToGrave()
		Duel.Overlay(c,rc,true)
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsCode(124162013) and c:IsControler(tp) and c:GetEquipTarget()
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,tp)>0
end
function s.tg2filter(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsAbleToChangeControler()
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,0,LOCATION_MZONE,nil,e)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_EQUIP)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,sg,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e):GetFirst()
	if not (tg and tg:IsLocation(LOCATION_MZONE) and tg:IsControler(1-tp) and c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 or not Duel.Equip(tp,tg,c,false) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetValue(function(e,mc) return mc==c end)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tg:RegisterEffect(e1)
end

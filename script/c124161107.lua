--독훼귀문관
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainNegatable(ev)
end

function s.tg1filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xf26) and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0 and c:IsCanBeEffectTarget(e)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg1filter(chkc,e,tp) end
	local rc=re:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil,e,tp)
	if chk==0 then return #g>0 and rc:IsAbleToRemove(tp) and Duel.IsPlayerCanRemove(tp) end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local tg=Duel.GetTargetCards(e):GetFirst()
	local ov=tg:GetOverlayGroup()
	local ovc=tg:GetOverlayCount()
	if not tg then return end
	Duel.SendtoGrave(ov,REASON_EFFECT)
	if not Duel.NegateActivation(ev) then return end
	local xg=Duel.GetMatchingGroup(Card.IsCanBeXyzMaterial,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if #xg==0 then return end
	Duel.BreakEffect()
	local xsg=aux.SelectUnselectGroup(xg+rc,e,tp,1,ovc,aux.TRUE,1,tp,HINTMSG_XMATERIAL)
	local x=xsg-xsg:Filter(Card.IsImmuneToEffect,nil,e)
	Duel.Overlay(tg,x,true)
	if rc:IsLocation(LOCATION_OVERLAY) then
		rc:CancelToGrave()
	end
end 

--effect 2
function s.con2filter(c)
	local og=c:GetOverlayGroup()
	return #og>0 and #og==og:FilterCount(Card.IsSetCard,nil,0xf26)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con2filter,tp,LOCATION_MZONE,0,nil)
	return g>0
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsSSetable() then
		Duel.SSet(tp,c)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1)
	end
end
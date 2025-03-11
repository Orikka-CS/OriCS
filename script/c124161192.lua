--페더록스 파라
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(_,c) return c:IsSetCard(0xf2c) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.tg3)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end

--effect 1
function s.val1filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()==0
end

function s.val1(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.val1filter,tp,LOCATION_MZONE,0,nil)
	local x=0
	if #g==0 then return 0 end
	for tc in aux.Next(g) do
		x=x+tc.minxyzct
	end
	return x*200
end

--effect 2
function s.tg2xfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e)
end

function s.tg2gfilter(c,e)
	return c:IsSetCard(0xf2c) and not c:IsType(TYPE_FIELD) and c:IsCanBeEffectTarget(e) and (c:IsAbleToHand() or c:IsCanBeXyzMaterial())
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g1=Duel.GetMatchingGroup(s.tg2xfilter,tp,LOCATION_MZONE,0,nil,e)
	local g2=Duel.GetMatchingGroup(s.tg2gfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return #g1>0 and #g2>0 end
	local sg1=aux.SelectUnselectGroup(g1,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	local sg2=aux.SelectUnselectGroup(g2,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	sg1:Merge(sg2)
	Duel.SetTargetCard(sg1)
	if sg1:GetFirst():GetOverlayCount()>0 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg2,1,0,0)
	end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg~=2 then return end
	local tg1=tg:Filter(Card.IsLocation,nil,LOCATION_MZONE):GetFirst()
	local tg2=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
	if tg1:GetOverlayCount()==0 then
		if tg2:IsCanBeXyzMaterial(tg1,tp) then
			Duel.Overlay(tg1,tg2)
		end
	else
		local og=tg1:GetOverlayGroup()
		if #og>0 then
			Duel.SendtoGrave(og,REASON_EFFECT)
		end
		Duel.SendtoHand(tg2,nil,REASON_EFFECT)
	end
end

--effect 3
function s.tg3(e,c)
	return c:IsSetCard(0xf2c) and c:GetOverlayCount()==0
end
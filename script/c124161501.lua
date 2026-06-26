--다이아보이드 세피로트
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
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf40) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_INACTIVATE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.con3)
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD)
	e3a:SetCode(EFFECT_CANNOT_DISEFFECT)
	e3a:SetRange(LOCATION_FZONE)
	e3a:SetCondition(s.con3)
	e3a:SetValue(s.val3)
	c:RegisterEffect(e3a)
end

--effect 1
function s.val1filter(c)
	return c:IsType(TYPE_XYZ) and not c:IsType(TYPE_EFFECT) and c:IsFaceup()
end

function s.val1(e,c)
	local g=Duel.GetMatchingGroup(s.val1filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	local ct=0
	for tc in g:Iter() do
		ct=ct+tc:GetOverlayCount()
	end
	return ct*200
end

--effect 2
function s.tg2filter(c,e)
	return c:IsType(TYPE_XYZ) and not c:IsType(TYPE_EFFECT) and c:IsFaceup() and c:IsCanBeEffectTarget(e)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return #g>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_OVERLAY)
end

function s.op2filter(c)
	return c:IsSetCard(0xf40) and not c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg and tg:IsFaceup() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 then
		Duel.DisableShuffleCheck()
		local dg=Duel.GetDecktopGroup(tp,1)
		Duel.Overlay(tg,dg,true)
		local g=tg:GetOverlayGroup():Filter(s.op2filter,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end

--effect 3
function s.con3filter(c)
	return c:IsType(TYPE_XYZ) and not c:IsType(TYPE_EFFECT) and c:IsFaceup()
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con3filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	return g>0
end

function s.val3(e,ct)
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return tp==e:GetHandlerPlayer() and te:GetHandler():IsSetCard(0xf40) and te:IsActiveType(TYPE_MONSTER)
end


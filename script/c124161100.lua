--Colosseum of Posion Demon
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
	e1:SetTarget(function(_,c) return c:IsSetCard(0xf26) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--effect 2
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.tg2)
	e3:SetOperation(s.op2)
	c:RegisterEffect(e3)
	--effect 3
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(s.con3)
	e4:SetOperation(s.op3)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end

--effect 1
function s.val1(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_XYZ)
	local x=0
	if #g==0 then return 0 end
	for tc in aux.Next(g) do
		x=x+tc:GetOverlayCount()
	end
	return x*200
end

--effect 2
function s.tg2filter(c,e)
	return c:IsSetCard(0xf26) and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e)
end

function s.tg2xfilter(c,e)
	return c:IsSetCard(0xf26) and not c:IsType(TYPE_FIELD)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg2filter(chkc) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,0,nil,e)
	local xg=Duel.GetMatchingGroup(s.tg2xfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 and #xg>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SELECT)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,sg:GetFirst():GetOverlayCount()*400)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local xg=Duel.GetMatchingGroup(s.tg2xfilter,tp,LOCATION_DECK,0,nil)
	local sg=Duel.GetFirstTarget()
	if sg:IsRelateToEffect(e) and #xg>0 then
		local sxg=aux.SelectUnselectGroup(xg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_XMATERIAL)
		Duel.Overlay(sg,sxg,true)
		Duel.BreakEffect()
		Duel.Damage(1-tp,sg:GetOverlayCount()*400,REASON_EFFECT)
	end
end

--effect 3
function s.con3filter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup()
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
	if not eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) then return false end
	local g=Duel.GetMatchingGroup(s.con3filter,tp,LOCATION_MZONE,0,nil)
	return #g>0
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,600,REASON_EFFECT)
end
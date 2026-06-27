--다이아보이드 스캐터링
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
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
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.con2)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2a:SetRange(LOCATION_SZONE)
	e2a:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2a:SetTargetRange(LOCATION_MZONE,0)
	e2a:SetCondition(s.con2)
	e2a:SetTarget(s.val2)
	e2a:SetValue(aux.tgoval)
	c:RegisterEffect(e2a)
end

--effect 1
function s.tg1xfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup()
end

function s.tg1filter(c,e)
	return c:IsType(TYPE_XYZ) and not c:IsType(TYPE_EFFECT) and c:IsFaceup() and c:IsCanBeEffectTarget(e) and c:GetOverlayCount()>0
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg1filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil,e)
	local xg=Duel.GetMatchingGroup(s.tg1xfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 and #xg>1 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.op1dfilter(c)
	return c:IsSetCard(0xf40) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end

function s.op1nfilter(c)
	return c:IsNegatable()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if not (tg and tg:IsFaceup()) then return end
	local og=tg:GetOverlayGroup()
	local xg=Duel.GetMatchingGroup(s.tg1xfilter,tp,LOCATION_MZONE,0,tg)
	if #og>0 and #xg>0 then
		local msg=aux.SelectUnselectGroup(og,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_XMATERIAL)
		local xsg=aux.SelectUnselectGroup(xg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_FACEUP):GetFirst()
		Duel.Overlay(xsg,msg)
		local dg=Duel.GetMatchingGroupCount(s.op1dfilter,tp,LOCATION_MZONE,0,nil)
		local ng=Duel.GetMatchingGroup(s.op1nfilter,tp,0,LOCATION_ONFIELD,nil)
		if dg>0 and #ng>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local nsg=aux.SelectUnselectGroup(ng,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_NEGATE):GetFirst()
			nsg:NegateEffects(e:GetHandler(),nil,true)
		end
	end
end

--effect 2
function s.con2filter(c)
	return c:IsType(TYPE_XYZ) and not c:IsType(TYPE_EFFECT) and c:IsFaceup()
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con2filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	return g>0
end

function s.val2(e,c)
	return c:IsFaceup() and not s.con2filter(c)
end
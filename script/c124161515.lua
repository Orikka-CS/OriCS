--페를라렌트 벤더 유다
local s,id=GetID()
function s.initial_effect(c)
	--fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf41),s.ffilter)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end

--fusion
function s.ffilter(c,fc,sumtype,tp)
	return c:GetEquipCount()>0
end

--effect 1
function s.tg1eqfilter(c,tp,tc)
	return c:IsSpell() and c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(tc) and c:CheckUniqueOnField(tp)
end

function s.tg1filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e) and Duel.GetMatchingGroupCount(s.tg1eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,tp,c)>0
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tg1filter(chkc,e,tp) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_MZONE,nil,e,tp)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsPlayerCanDraw(tp,1) end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_FACEUP)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if not (tg and tg:IsFaceup()) then return end
	local g=Duel.GetMatchingGroup(s.tg1eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,tp,tg)
	if #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_EQUIP):GetFirst()
		Duel.Equip(tp,sg,tg)
		if Duel.IsPlayerCanDraw(tp,1) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

--effect 2
function s.con2filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(s.con2filter,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil)>0
end

function s.tg2(e,c)
	return c:IsSetCard(0xf41)
end
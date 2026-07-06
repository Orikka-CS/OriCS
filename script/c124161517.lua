--페를라렌트 이우데카
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
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf41) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_EQUIP)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(s.tg3)
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
end

--effect 1
function s.val1filter(c)
	return c:IsSpell() and c:IsType(TYPE_EQUIP) and c:IsReason(REASON_DESTROY)
end

function s.val1(e,c)
	return Duel.GetMatchingGroupCount(s.val1filter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)*100
end

--effect 2
function s.con2eqfilter(c,tp,tc)
	return c:IsControler(tp) and c:GetEquipTarget()==tc and tc:IsControler(1-tp)
end

function s.con2filter(c,tp,eg)
	return c:IsFaceup() and c:IsAbleToChangeControler() and eg:IsExists(s.con2eqfilter,1,nil,tp,c)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(s.con2filter,tp,0,LOCATION_MZONE,nil,tp,eg)>0
end

function s.tg2dfilter(c)
	return c:IsSetCard(0xf41) and not c:IsType(TYPE_FIELD)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2dfilter,tp,LOCATION_DECK,0,nil)
	local mg=Duel.GetMatchingGroup(s.con2filter,tp,0,LOCATION_MZONE,nil,tp,eg)
	if chk==0 then return #g>0 and #mg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,LOCATION_MZONE)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2dfilter,tp,LOCATION_DECK,0,nil)
	local mg=Duel.GetMatchingGroup(s.con2filter,tp,0,LOCATION_MZONE,nil,tp,eg)
	if #g>0 and #mg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DESTROY)
		local res=Duel.Destroy(sg,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
		if res>0 then
			Duel.BreakEffect()
			local tc=aux.SelectUnselectGroup(mg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONTROL):GetFirst()
			Duel.GetControl(tc,tp)
		end
	end
end

--effect 3
function s.tg3(e,c)
	local ec=c:GetEquipTarget()
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsControler(e:GetHandlerPlayer()) and ec and ec:GetOwner()==1-e:GetHandlerPlayer()
end

function s.val3(e,te)
	return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActivated()
end
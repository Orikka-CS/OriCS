--란샤르드 아바리스
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.con2)
	e2:SetTargetRange(0,1)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1filter(c,tp)
	return c:IsControler(1-tp) and c:GetOwner()==tp and not c:IsReason(REASON_DRAW)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.con1filter,1,nil,tp)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,1,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.con1filter,nil,tp)
	g=g:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if Duel.Draw(tp,1,REASON_EFFECT)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

--effect 2
function s.con2filter(c)
	return c:IsSetCard(0xf2e) and c:IsType(TYPE_FUSION) and c:IsFaceup()
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroupCount(s.con2filter,tp,LOCATION_MZONE,0,nil)
	return g>0
end

function s.val2(e,re,tp)
	local rc=re:GetHandler()
	return re:GetActivateLocation()==LOCATION_GRAVE and rc:IsMonster() and rc:IsPreviousLocation(LOCATION_HAND)
end
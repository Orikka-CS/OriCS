--Eclipse Umbrare
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
	e1:SetTarget(function(_,c) return c:IsSetCard(0xf22) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--effect 2
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.con2i)
	e3:SetTarget(s.tg2i)
	e3:SetOperation(s.op2i)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCondition(s.con2o)
	e4:SetTarget(s.tg2o)
	e4:SetOperation(s.op2o)
	c:RegisterEffect(e4)
	--effect 3
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_FZONE)
	e5:SetOperation(s.op3)
	c:RegisterEffect(e5)
end

--effect 1
function s.val1(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_STZONE,LOCATION_STZONE,nil)*200
end

--effect 2
function s.con2i(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and re:GetHandler():GetOwner()==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsSetCard(0xf22) and not re:GetHandler():IsType(TYPE_FIELD) 
end

function s.tg2ifilter(c)
	return c:IsSetCard(0xf22) and c:IsMonster() and c:IsAbleToHand() 
end

function s.tg2i(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2ifilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
end

function s.op2i(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2ifilter,tp,LOCATION_GRAVE,0,nil)
	if #g<1 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end

function s.con2o(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:GetHandler():GetOwner()==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsSetCard(0xf22) and not re:GetHandler():IsType(TYPE_FIELD)
end

function s.tg2ofilter(c)
	return c:IsSetCard(0xf22) and c:IsSSetable() and (c:IsType(TYPE_QUICKPLAY) or c:IsType(TYPE_TRAP)) 
end

function s.tg2o(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2ofilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end

function s.op2o(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2ofilter,tp,LOCATION_GRAVE,0,nil)
	if #g<1 and Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND):GetFirst()
	Duel.SSet(tp,sg)
end

--effect 3
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if ep==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(function(_e,_rp,_tp) return _tp==_rp end)
	end
end
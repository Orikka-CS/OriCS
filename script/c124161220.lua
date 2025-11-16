--란샤르드 시트류
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.cst1filter(c,tp)
	return c:IsSetCard(0xf2e) and c:GetOwner()==tp and  c:IsAbleToGraveAsCost()
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_HAND,0,c,tp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(sg,REASON_COST)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)&LOCATION_MZONE)~=0 and rp==1-tp and re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsLocation(LOCATION_MZONE)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local c=e:GetHandler()
	if chk==0 then return rc:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,rc,1,tp,LOCATION_MZONE)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local c=e:GetHandler()
	if rc:IsRelateToEffect(re) and c:IsRelateToEffect(e) then
		local g=Group.FromCards(c,rc)
		Duel.SendtoHand(g,1-tp,REASON_EFFECT)
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE) and c:IsAbleToHand()
end

function s.con2(e,tp,eg)
	local c=e:GetHandler()
	return eg:FilterCount(s.con2filter,nil,tp)>0 and c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_HAND)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.con2filter,nil,tp)
	if chk==0 then return #g>0 and e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g+e:GetHandler(),1,tp,LOCATION_MZONE)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.con2filter,nil,tp)
	local c=e:GetHandler()
	if #g>0 and c:IsRelateToEffect(e) then
		g=g+c
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
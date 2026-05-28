--언엔달 리커전
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler()
end

function s.tg1eqfilter(c)
	return c:IsCode(124161059)
end

function s.tg1filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf23)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil)
	local eg=Duel.GetMatchingGroup(s.tg1eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	if chk==0 then return #mg>0 and #eg>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	if rp==1-tp and re:IsMonsterEffect() and Duel.IsChainDisablable(ev) then
		e:SetLabel(1)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	else
		e:SetLabel(0)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,eg,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil)
	local eg=Duel.GetMatchingGroup(s.tg1eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	if #mg>0 and #eg>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local esg=aux.SelectUnselectGroup(eg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_EQUIP):GetFirst()
		local msg=aux.SelectUnselectGroup(mg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_EQUIP):GetFirst()
		Duel.Equip(tp,esg,msg)
	end
	if e:GetLabel()==1 then
		Duel.NegateEffect(ev)
	end
end

--effect 2
function s.tg2filter(c,e)
	return c:IsSetCard(0xf23) and c:IsFaceup() and c:IsCanBeEffectTarget(e) 
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g1=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_ONFIELD,0,e:GetHandler(),e)
	local g2=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,0,LOCATION_SZONE,e:GetHandler(),e) 
	if chk==0 then return #g1>0 and #g2>0 end
	local sg1=aux.SelectUnselectGroup(g1,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_RTOHAND)
	local sg2=aux.SelectUnselectGroup(g2,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_RTOHAND)
	sg1:Merge(sg2)
	Duel.SetTargetCard(sg1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg1,2,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
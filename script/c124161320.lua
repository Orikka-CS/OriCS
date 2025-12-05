--이지러지는 허월상
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Fusion.CreateSummonEff({handler=c,extrafil=s.extrafil})
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsSetCard,1,nil,0xf34,fc,SUMMON_TYPE_FUSION,tp)
end

function s.extrafil(e,tp,mg,sumtype)
	return Group.CreateGroup(),s.fcheck
end

--effect 2
function s.cst2filter(c)
	return c:IsSetCard(0xf34) and c:IsMonster() and c:IsReason(REASON_FUSION+REASON_MATERIAL) and c:IsAbleToRemoveAsCost()
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,LOCATION_GRAVE)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
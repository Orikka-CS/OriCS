--Astaterea Sagitta
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
--effect 1
function s.con1filter(c)
	return c:IsSetCard(0xf25) and c:IsMonster() and c:IsFaceup()
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_MZONE,0,nil)
	return g>0
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	local ug=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	local dg=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	local rg=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return math.abs(ug-dg)>0 and #rg>0 end
	local sg=aux.SelectUnselectGroup(rg,e,tp,1,math.abs(ug-dg),aux.TRUE,1,tp,HINTMSG_REMOVE)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
	if math.abs(ug-dg)>2 then
		Duel.SetChainLimit(s.chlimit)
	end
end

function s.chlimit(e,ep,tp)
	return tp==ep
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0xf25)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp and c:IsPreviousLocation(LOCATION_MZONE)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.con2filter,1,nil,tp)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsSSetable() and Duel.SSet(tp,c)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1)
	end
end
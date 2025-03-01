--클라랑슈 푸르가토리움
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c)
	return c:IsSetCard(0xf2d) and c:IsMonster() and c:IsFaceup()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	local ct=Duel.GetMatchingGroupCount(s.tg1filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 and ct>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	local ct=Duel.GetMatchingGroupCount(s.tg1filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if #g>0 and ct>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.TRUE,1,tp,HINTMSG_TODECK)
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		local tkt=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
		if not Duel.IsPlayerCanSpecialSummonMonster(1-tp,124161198,0xf2d,TYPES_TOKEN,0,0,1,RACE_REPTILE,ATTRIBUTE_WIND) then return end
		tkt=math.min(tkt,ft)
		if Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			for i=1,tkt do
				local token=Duel.CreateToken(1-tp,124161198)
				Duel.SpecialSummonStep(token,0,1-tp,1-tp,false,false,POS_FACEUP)
			end
			Duel.SpecialSummonComplete()
		end
	end
end

--effect 2
function s.con2filter(c)
	local mg=c:GetMaterial()
	return c:IsType(TYPE_LINK) and #mg>0 and #mg~=mg:FilterCount(Card.IsType,nil,TYPE_EFFECT) and c:IsFaceup()
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con2filter,tp,LOCATION_MZONE,0,nil)
	return g>0
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
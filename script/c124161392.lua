--콘트라기온 메피스 티포이드
local s,id=GetID()
function s.initial_effect(c)
	--synchro
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.tg3)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end

--effect 1
function s.con1filter(c,tp)
	return c:IsSetCard(0xf39) and c:IsControler(tp)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con1filter,nil,tp)>0
end

function s.tg1filter(c)
	return c:IsAbleToRemove()
end

function s.tg1c1filter(c)
	return c:IsCode(124161384) and c:IsFaceup()
end

function s.tg1c2filter(c)
	return c:IsType(TYPE_TUNER) and c:IsFaceup()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct1=Duel.GetMatchingGroupCount(s.tg1c1filter,tp,LOCATION_GRAVE,0,nil)
	local ct2=Duel.GetMatchingGroupCount(s.tg1c2filter,tp,0,LOCATION_MZONE,nil)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return (ct1+ct2)>0 and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end

function s.op1dfilter(c)
	return c:IsCode(124161384) and c:IsAbleToDeck()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local ct1=Duel.GetMatchingGroupCount(s.tg1c1filter,tp,LOCATION_GRAVE,0,nil)
	local ct2=Duel.GetMatchingGroupCount(s.tg1c2filter,tp,0,LOCATION_MZONE,nil)
	local max=ct1+ct2
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_ONFIELD,nil)
	if max>0 and #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,max,aux.TRUE,1,tp,HINTMSG_REMOVE)
		if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)>0 then
			local jg=Duel.GetMatchingGroup(s.op1dfilter,tp,LOCATION_GRAVE,0,nil)
			if #jg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.BreakEffect()
				local jsg=aux.SelectUnselectGroup(jg,e,tp,1,#jg,aux.TRUE,1,tp,HINTMSG_TODECK)
				Duel.SendtoDeck(jsg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end

--effect 2
function s.con2filter(c)
	return c:IsFaceup() and c:IsCode(124161384)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainNegatable(ev) and Duel.GetMatchingGroupCount(s.con2filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)>0
end

function s.tg2filter(c)
	return c:IsCode(124161384) and c:IsAbleToDeck()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
	Duel.SetChainLimit(function(e,ep,tp) return ep==tp or not (e:IsActiveType(TYPE_MONSTER) and e:GetHandler():IsType(TYPE_TUNER)) end)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end

--effect 3
function s.tg3(e,c)
	return c:IsType(TYPE_TUNER)
end
--폴루스턴 크리매토리
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
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf36) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_LVCHANGE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTarget(s.tg3)
	e3:SetOperation(s.op3)
	e3:SetValue(function(e,c) return s.val3filter(c,e,e:GetHandlerPlayer()) end)
	c:RegisterEffect(e3)
end

--effect 1
function s.val1filter(c)
	return c:GetLevel()<c:GetOriginalLevel()
end

function s.val1(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.val1filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local x=0
	if #g==0 then return 0 end
	for tc in aux.Next(g) do
		x=x+tc:GetOriginalLevel()-tc:GetLevel()
	end
	return x*100
end

--effect 2
function s.con2filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil)>0
end

function s.tg2ctfilter(c)
	return c:IsSetCard(0xf36) and not c:IsType(TYPE_FIELD) and c:IsAbleToDeck()
end

function s.tg2filter(c,e)
	return c:IsFaceup() and c:IsLevelAbove(2) and c:IsCanBeEffectTarget(e)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tg2filter(chkc,e) end
	local ct=Duel.GetMatchingGroupCount(s.tg2ctfilter,tp,LOCATION_GRAVE,0,nil)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return ct>0 and #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end

function s.op2filter(c)
	return c:IsFaceup() and not c:IsLevelAbove(2)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	local g=Duel.GetMatchingGroup(s.tg2ctfilter,tp,LOCATION_GRAVE,0,nil)
	if tg and tg:IsFaceup() and #g>0 then
		local max=math.min(#g,tg:GetLevel()-1)
		if max<=0 then return end
		local sg=aux.SelectUnselectGroup(g,e,tp,1,max,aux.TRUE,1,tp,HINTMSG_TODECK)
		if #sg>0 then
			local ct=Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(-ct)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tg:RegisterEffect(e1)
			local dg=Duel.GetMatchingGroup(s.op2filter,tp,0,LOCATION_MZONE,nil)
			if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.BreakEffect()
				local dsg=aux.SelectUnselectGroup(dg,e,tp,1,ct,aux.TRUE,1,tp,HINTMSG_DESTROY)
				Duel.Destroy(dsg,REASON_EFFECT)
			end
		end
	end
end

--effect 3
function s.val3filter(c,e,tp)
	return c:IsControler(tp) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c~=e:GetHandler()
end

function s.tg3filter(c)
	return c:IsSetCard(0xf36) and c:IsFaceup() and c:IsLevelAbove(2)
end

function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg3filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return eg:FilterCount(s.val3filter,nil,e,tp)>0 and #g>0 end
	return Duel.SelectYesNo(tp,aux.Stringid(id,1))
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg3filter,tp,LOCATION_MZONE,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_FACEUP):GetFirst()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(-1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	sg:RegisterEffect(e1)
	return true
end
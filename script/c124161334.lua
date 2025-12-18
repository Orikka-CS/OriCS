--스노위퍼 메뉴버
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
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

function s.tg1filter(c,e)
	return c:IsSetCard(0xf35) and c:IsCanBeEffectTarget(e) and c:IsFaceup()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg1filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil,e,tp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	local ch=Duel.GetCurrentChain()-1
	local trig_p,trig_e=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
	if ch>0 and trig_p==1-tp and Duel.IsChainDisablable(ch)
		then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end

function s.op1filter(c)
	return c:IsSetCard(0xf35) and (c:GetSequence()==0 or c:GetSequence()==4) and c:IsFaceup()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg:IsRelateToEffect(e) and tg:IsControler(tp) and not tg:IsImmuneToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		Duel.MoveSequence(tg,math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0),2))
		local ct=Duel.GetMatchingGroupCount(s.op1filter,tp,LOCATION_MZONE,0,nil)
		local ch=Duel.GetCurrentChain()-1
		if ct>0 and e:GetLabel()==1 then
			Duel.NegateEffect(ch)
		end
	end
end

--effect 2
function s.con2filter(c)
	return c:GetSequence()==0 or c:GetSequence()==4
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con2filter,tp,0,LOCATION_ONFIELD,nil)
	return g>0
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
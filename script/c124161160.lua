--휴프알로 퀸 바쿠아
local s,id=GetID()
function s.initial_effect(c)
	--xyz
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,9,3,s.ovfilter,aux.Stringid(id,0),3,s.ovop)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.DetachFromSelf(1,1,nil))
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--xyz
function s.ovfilter(c,tp,lc)
	return c:IsFacedown() and c:IsCanBeXyzMaterial() and c:IsControler(tp) and c:IsRank(6) and c:IsSetCard(0xf2a)
end

function s.ovop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end

--effect 1
function s.tg1filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xf2a) and c:IsCanTurnSet()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local fg=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #fg>0 end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,fg,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local fg=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil)
	if #fg>0 then
		local fsg=aux.SelectUnselectGroup(fg,e,tp,1,#fg,aux.TRUE,1,tp,HINTMSG_POSCHANGE)
		Duel.ChangePosition(fsg,POS_FACEDOWN_DEFENSE)
		local rg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
		if #rg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			local rsg=aux.SelectUnselectGroup(rg,e,tp,1,#fsg,aux.TRUE,1,tp,HINTMSG_TODECK)
			Duel.SendtoDeck(rsg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)&LOCATION_ONFIELD)~=0 and rp==1-tp
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFacedown() end
	Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
	if #g==0 then return end
	for tc in aux.Next(g) do
		tc:NegateEffects(c,RESET_PHASE+PHASE_END,true)
	end
end
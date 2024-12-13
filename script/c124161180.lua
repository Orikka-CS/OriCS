--혼화의 백연초
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Fusion.CreateSummonEff({handler=c,extrafil=s.extrafil,extratg=s.extratg,extraop=s.extraop})
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--count
	aux.GlobalCheck(s,function()
		local cnt=Effect.CreateEffect(c)
		cnt:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		cnt:SetCode(EVENT_PAY_LPCOST)
		cnt:SetOperation(s.cnt)
		Duel.RegisterEffect(cnt,0)
	end)
end

--count
function s.cnt(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,1)
end

--effect 1
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsSetCard,nil,0xf2b)>0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=Duel.GetFlagEffect(tp,124161180)
end

function s.extrafil(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE,0,nil),s.fcheck
end

function s.extraop(e,tc,tp,sg)
	local g=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(g)
	end
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end

--effect 2
function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() and Duel.CheckLPCost(tp,800) end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	Duel.PayLPCost(tp,800)
end

function s.tg2filter(c,e)
	return c:IsSetCard(0xf2b) and c:IsType(TYPE_FUSION) and c:IsFaceup() and c:IsCanBeEffectTarget(e)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetFirstTarget()
	if not (tg:IsRelateToEffect(e) and tg:IsFaceup()) then return end
	local c=e:GetHandler()
	if not tg:IsImmuneToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(s.op2imfilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tg:RegisterEffect(e1)
	end
end

function s.op2imfilter(e,te)
	return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActivated() and te:IsActiveType(TYPE_SPELL)
end
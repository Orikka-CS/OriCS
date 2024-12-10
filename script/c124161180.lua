--혼화의 백연초
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Fusion.CreateSummonEff({handler=c,extrafil=s.extrafil,extratg=s.extratg,extraop=s.extraop})
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetCost(aux.bfgcost)
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
function s.con2filter(c,e,tp)
	return c:IsSetCard(0xf2b) and c:IsType(TYPE_FUSION) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and c:IsCanBeEffectTarget(e) and c:GetBaseAttack()>0 and c:GetBaseDefense()>0 and c:IsReason(REASON_BATTLE+REASON_EFFECT) 
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,e,tp)>0
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.con2filter,nil,e,tp)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) end
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetFirstTarget()
	if tg:IsRelateToEffect(e) then
		Duel.Recover(tp,tg:GetBaseAttack(),REASON_EFFECT)
		Duel.Damage(1-tp,tg:GetBaseDefense(),REASON_EFFECT)
	end
end
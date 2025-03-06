--페더록스리더 라피더스
local s,id=GetID()
function s.initial_effect(c)
	--xyz
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf2c),4,3)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c,e)
	return c:IsSetCard(0xf2c) and c:IsCanBeEffectTarget(e) and c:IsFaceup() and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tg1filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_REMOVED,0,nil,e)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_RTOHAND)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_MZONE)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetFirstTarget()
	if tg:IsRelateToEffect(e) then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE)
			aux.RemoveUntil(sg,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp)
		end
	end
end

--effect 2
function s.con2filter(c,tp)
	return not c:IsSummonLocation(LOCATION_REMOVED) and c:IsAbleToRemove() and c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE)
end

function s.con2(e,tp,eg)
	local c=e:GetHandler()
	return not eg:IsContains(c) and eg:FilterCount(s.con2filter,nil,tp)>0 and e:GetHandler():GetOverlayCount()==0
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,#eg,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,eg,#eg,1-tp,LOCATION_REMOVED)
	Duel.SetChainLimit(function(e,ep,tp) return ep==tp end)
end

function s.op2filter(c,e,tp)
	return c:IsLocation(LOCATION_REMOVED) and not c:IsReason(REASON_REDIRECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.con2filter,nil,tp)
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT) then
		pg=g:Filter(s.op2filter,nil,e,1-tp)
		if #pg>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.SpecialSummon(pg,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
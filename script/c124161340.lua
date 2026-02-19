--폴루스턴 나이트로
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_LVCHANGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_ADD_TYPE)
	e3:SetRange(LOCATION_MZONE)  
	e3:SetCondition(function(e) return e:GetHandler():GetLevel()<e:GetHandler():GetOriginalLevel() end)
	e3:SetValue(TYPE_TUNER)
	c:RegisterEffect(e3)
end

--effect 1
function s.tg1ffilter(c,e,tp,cd)
	return c:IsSetCard(0xf36) and not c:IsCode(cd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tg1filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xf36) and c:IsLevelAbove(2) and c:IsCanBeEffectTarget(e)
		and Duel.GetMatchingGroupCount(s.tg1ffilter,tp,LOCATION_DECK,0,nil,e,tp,c:GetCode())>0
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg1filter(chkc,e,tp) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil,e,tp)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg and tg:IsFaceup() and tg:IsRelateToEffect(e) and not tg:IsImmuneToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tg:RegisterEffect(e1)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			local g=Duel.GetMatchingGroup(s.tg1ffilter,tp,LOCATION_DECK,0,nil,e,tp,tg:GetCode())
			if #g>0 then
				local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end

function s.tg2filter(c,e)
	return c:IsFaceup() and c:IsSetCard(0xf36) and c:IsCanBeEffectTarget(e) and c:GetLevel()<c:GetOriginalLevel()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,0,nil,e)
	local dg=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 and dg>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg and tg:IsFaceup() and tg:IsRelateToEffect(e) then
		local diff=tg:GetOriginalLevel()-tg:GetLevel()
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		if diff>0 and #g>0 then
			local sg=aux.SelectUnselectGroup(g,e,tp,1,diff,aux.TRUE,1,tp,HINTMSG_DESTROY)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
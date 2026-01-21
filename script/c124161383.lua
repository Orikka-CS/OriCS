--스큐드라스 임페커블리티
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainNegatable(ev)
end

function s.tg1spfilter(c,e,tp)
	return c:IsSetCard(0xf38) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tg1filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xf38) and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e) and c:GetOverlayGroup():FilterCount(s.tg1spfilter,nil,e,tp)>0
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg1filter(chkc,e,tp) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil,e,tp)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_OVERLAY)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.op1filter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN) and (c:IsType(TYPE_MONSTER) or c:IsType(TYPE_CONTINUOUS+TYPE_FIELD+TYPE_EQUIP) or c:IsLocation(LOCATION_PZONE))
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg and tg:IsFaceup() and tg:IsRelateToEffect(e) and tg:GetOverlayGroup():IsExists(s.tg1spfilter,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local g=tg:GetOverlayGroup():Filter(s.tg1spfilter,nil,e,tp)
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON):GetFirst()
		if sg and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
			if Duel.NegateActivation(ev) then
				Duel.BreakEffect()
				local og=Duel.GetMatchingGroup(s.op1filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,sg)
				if #og>0 then
					Duel.Overlay(sg,og)
				end
			end
		end
	end
end
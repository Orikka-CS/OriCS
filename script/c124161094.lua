--실의 독훼귀-지주
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.con3)
	e3:SetTarget(s.tg3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end

--effect 1
function s.con1filter(c)
	return c:IsSetCard(0xf26)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_GRAVE,0,nil)
	return g>0
end

function s.tg1filter(c)
	return c:IsTrap() and c:IsSetCard(0xf26) and c:IsSSetable()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and #g>0 end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SET):GetFirst()
		Duel.SSet(tp,sg) 
	end
end

--effect 2
function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,2,REASON_COST) end
	Duel.RemoveOverlayCard(tp,1,0,1,2,REASON_COST)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
			Duel.Damage(1-tp,300,REASON_EFFECT)
		end
	end
end

--effect 3
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_OVERLAY) and (c:IsReason(REASON_COST) or c:IsReason(REASON_EFFECT))
end

function s.tg3filter(c,e)
	return c:IsRace(RACE_INSECT) and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e)
end

function s.tg3xfilter(c,e)
	return c:IsSetCard(0xf26) and not c:IsCode(id)
end

function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg3filter,tp,LOCATION_MZONE,0,nil,e)
	local xg=Duel.GetMatchingGroup(s.tg3xfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 and #xg>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SELECT)
	Duel.SetTargetCard(sg)
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local xg=Duel.GetMatchingGroup(s.tg3xfilter,tp,LOCATION_GRAVE,0,nil)
	local sg=Duel.GetFirstTarget()
	if sg:IsRelateToEffect(e) and #xg>0 then
		local sxg=aux.SelectUnselectGroup(xg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_XMATERIAL)
		Duel.Overlay(sg,sxg,true)
	end
end

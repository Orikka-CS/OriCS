--스큐드라스 릴링
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c)
	return c:IsSetCard(0xf38) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.op1mfilter(c)
	return c:IsSetCard(0xf38) and c:IsMonster()
end

function s.op1xfilter(c)
	return c:IsSetCard(0xf38) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		local mg=Duel.GetMatchingGroup(s.op1mfilter,tp,LOCATION_DECK,0,nil)
		local xg=Duel.GetMatchingGroup(s.op1xfilter,tp,LOCATION_MZONE,0,nil)
		if #mg>0 and #xg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local msg=aux.SelectUnselectGroup(mg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_XMATERIAL):GetFirst()
			local xsg=aux.SelectUnselectGroup(xg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_FACEUP):GetFirst()
			Duel.Overlay(xsg,msg,true)
		end
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsSetCard(0xf38) and c:IsControler(tp) and c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,tp)>0
end

function s.tg2xfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup()
end

function s.tg2filter(c,e,tp)
	return s.con2filter(c,tp) and c:IsCanBeEffectTarget(e) and Duel.GetMatchingGroupCount(s.tg2xfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,c)>0
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg2filter(chkc,e,tp) end
	local g=eg:Filter(s.tg2filter,nil,e,tp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	local g=Duel.GetMatchingGroup(s.tg2xfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,tg)
	if tg and #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_XMATERIAL)
		Duel.Overlay(tg,sg)
	end
end
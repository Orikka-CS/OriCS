--엔비램블 맬리스
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1ctfilter(c)
	return c:IsSetCard(0xf3f) and c:IsFaceup()
end

function s.tg1filter(c,e)
	return c:IsFaceup() and c:IsCanBeLinkMaterial() and c:IsCanBeEffectTarget(e)
end

function s.linkfilter(c,mg)
	return c:IsLinkSummonable(nil,mg,#mg,#mg)
end

function s.rescon(sg,e,tp,mg)
	return Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_EXTRA,0,1,nil,sg)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(s.tg1ctfilter,tp,LOCATION_ONFIELD,0,c)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return ct>0 and aux.SelectUnselectGroup(g,e,tp,ct,ct,s.rescon,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,ct,ct,s.rescon,1,tp,HINTMSG_LMATERIAL)
	Duel.SetTargetCard(sg)
	e:SetLabel(#sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.op1filter(c,e)
	return c:IsFaceup() and c:IsCanBeLinkMaterial() and not c:IsImmuneToEffect(e)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):Filter(s.op1filter,nil,e)
	if #tg==e:GetLabel() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.linkfilter,tp,LOCATION_EXTRA,0,1,1,nil,tg)
		local sc=sg:GetFirst()
		if sc then
			Duel.LinkSummon(tp,sc,tg,tg,#tg,#tg)
		end
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsSetCard(0xf3f) and c:IsMonster() and c:IsReason(REASON_LINK) and c:IsControler(tp)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,tp)>0
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,LOCATION_GRAVE)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
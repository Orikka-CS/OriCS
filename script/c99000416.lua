--인조천사 메타트론
local s,id=GetID()
function s.initial_effect(c)
	--Link summon
	Link.AddProcedure(c,s.matfilter,2,2)
	c:EnableReviveLimit()
	--자신 필드에 "인조천사"가 존재하고, 상대 필드에 천사족 몬스터가 엑스트라 덱에서 특수 소환되었을 경우, 이 카드를 링크 소환할 수 있다.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--이하의 효과에서 1개를 적용한다.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	--그 카드를 파괴한다.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_MZONE)
	e3:SetSpellSpeed(3)
	e3:SetCondition(s.ddcon)
	e3:SetCost(s.ddcost)
	e3:SetTarget(s.ddtg)
	e3:SetOperation(s.ddop)
	c:RegisterEffect(e3)
	--이 효과의 발동은 카운터 함정 카드의 발동으로도 취급한다.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_ACTIVATE_COST)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	e4:SetTarget(function(e,te,tp) return te==e:GetLabelObject() end)
	e4:SetOperation(
	function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TRAP+TYPE_COUNTER)
		e1:SetReset(RESET_CHAIN)
		c:RegisterEffect(e1,true)
	end)
	e4:SetLabelObject(e3)
	Duel.RegisterEffect(e4,0)
end
s.listed_names={16946849}
s.listed_series={0xc12}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsRace(RACE_FAIRY,scard,sumtype,tp) and c:IsAttribute(ATTRIBUTE_LIGHT,scard,sumtype,tp)
end
function s.spfilter(c,tp)
	return c:IsControler(1-tp) and c:IsRace(RACE_FAIRY) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil,tp) and e:GetHandler():IsLinkSummonable()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,16946849),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLinkSummonable() and Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,0)) then
		Duel.LinkSummon(tp,c,nil)
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:IsAbleToHand()
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_COUNTER) or not c:IsLocation(LOCATION_MZONE) or not c:IsFaceup() then return end
	Duel.Hint(HINT_CARD,0,id)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,0,nil)
	local b2=#g>1
	local op=Duel.SelectEffect(tp,{true,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)},{true,aux.Stringid(id,3)})
	Duel.BreakEffect()
	if op==1 then
		Duel.Draw(tp,1,REASON_EFFECT)
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,2,2,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	elseif op==3 then
		Duel.Recover(tp,1000,REASON_EFFECT)
		if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,16946849),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.Synthetic_Seraphim_Filter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsRace(RACE_FAIRY)
end
function s.ddcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.Synthetic_Seraphim_Filter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil) then
		return true
	else
		return Duel.GetFlagEffect(tp,id)<1
	end
end
function s.ddcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.ddfilter(c,tp)
	return c:IsControler(1-tp)
end
function s.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.ddfilter,nil,tp)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return #g>0 and Duel.CheckLPCost(tp,1400)
	end
	e:SetLabel(0)
	Duel.PayLPCost(tp,1400)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
function s.ddop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=eg:Filter(s.ddfilter,nil,tp)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
--고고한 흉광(노바에페르 오블리비언)
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,8,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)
	c:EnableReviveLimit()
	--이 카드는 엑시즈 소환된 턴에는 엑시즈 소재로 할 수 없다.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetCondition(s.xyzcon)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--자신 메인 페이즈 2 이외에는, 이 카드는 다른 카드의 효과를 받지 않는다.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.imcon)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--그 카드를 파괴한다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetCondition(aux.NOT(s.quickcon))
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--자신 필드에 다른 몬스터가 존재하지 않을 경우, 이 효과는 상대 턴에도 발동할 수 있다
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3)
	--이 턴에 파괴되어 자신이나 상대 묘지로 보내진 카드 1장을 이 카드의 엑시즈 소재로 한다.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.dattchtg)
	e4:SetOperation(s.dattchop)
	c:RegisterEffect(e4)
end
s.listed_names={id}
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and not c:IsInExtraMZone(tp) 
		and Duel.GetCurrentPhase()==PHASE_MAIN2 and c:IsType(TYPE_MONSTER,lc,SUMMON_TYPE_XYZ,tp)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	return true
end
function s.xyzcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsXyzSummoned()
end
function s.imcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() or Duel.GetCurrentPhase()~=PHASE_MAIN2
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.dattchfilter(c,xyzc,tp,tid)
	return c:GetTurnID()==tid and (c:GetReason()&REASON_DESTROY)~=0 and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end
function s.dattchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tid=Duel.GetTurnCount()
	if chk==0 then
		local c=e:GetHandler()
		return c:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.dattchfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,c,tp,tid)
	end
end
function s.dattchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tid=Duel.GetTurnCount()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	local g=Duel.SelectMatchingCard(tp,s.dattchfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,c,tp,tid)
	if #g>0 then
		Duel.Overlay(c,g)
	end
end
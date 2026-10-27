--언엔달 리커전
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c,e,tp)
	return c:IsSetCard(0x3f20) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeEffectTarget(e)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tg1filter(chkc,e,tp) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end
function s.op1filter(c,tp,mc)
	return c:IsCode(124162013) and c:CheckUniqueOnField(tp) and c:CheckEquipTarget(mc)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if not tg or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 or Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local g=Duel.GetMatchingGroup(s.op1filter,tp,LOCATION_GRAVE,0,nil,tp,tg)
	if #g>0 and tg:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_EQUIP):GetFirst()
		Duel.Equip(tp,sg,tg)
	end
end

--effect 2
function s.tg2filter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x3f20) and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e)
end
function s.tg2matfilter(c)
	return c:IsSetCard(0x3f20) and not c:IsCode(id)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,0,nil,e)
	local mg=Duel.GetMatchingGroup(s.tg2matfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 and #mg>0 and Duel.GetFlagEffect(tp,124162013)>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_FACEUP)
	Duel.SetTargetCard(sg)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	local g=Duel.GetMatchingGroup(s.tg2matfilter,tp,LOCATION_GRAVE,0,nil)
	local ct=Duel.GetFlagEffect(tp,124162013)
	if tg and tg:IsFaceup() and tg:IsType(TYPE_XYZ) and not tg:IsImmuneToEffect(e) and #g>0 and ct>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,math.min(ct,#g),aux.TRUE,1,tp,HINTMSG_XMATERIAL)
		Duel.Overlay(tg,sg)
	end
end

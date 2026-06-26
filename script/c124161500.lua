--다이아보이드 산달폰 피렌체
local s,id=GetID()
function s.initial_effect(c)
	--xyz
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.xyzfilter,nil,2,nil,nil,nil,nil,false)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.DetachFromSelf(1,1,nil))
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--xyz
function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsType(TYPE_XYZ,xyz,sumtype,tp) and c:IsRank(4) and c:IsSetCard(0xf40,xyz,sumtype,tp)
end

--effect 1
function s.tg1filter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and not c:IsType(TYPE_EFFECT) and c:IsCanBeEffectTarget(e)
end

function s.tg1ofilter(c,e)
	return (c:IsAbleToChangeControler() or not c:IsLocation(LOCATION_ONFIELD)) and not c:IsType(TYPE_TOKEN) and not c:IsImmuneToEffect(e)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg1filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil,e)
	local og=Duel.GetMatchingGroup(s.tg1ofilter,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,nil,e)
	if chk==0 then return #g>0 and #og>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if not (tg and tg:IsRelateToEffect(e)) then return end
	local hg=Duel.GetMatchingGroup(s.tg1ofilter,tp,0,LOCATION_HAND,nil,e)
	local g=Duel.GetMatchingGroup(s.tg1ofilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil,e)
	if #hg+#g==0 then return end
	local sg=Group.CreateGroup()
	if #g==0 or (#hg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
		sg=hg:RandomSelect(tp,1)
	else
		sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_XMATERIAL)
	end
	Duel.Overlay(tg,sg,true)
end

--effect 2
function s.tg2spfilter(c,e,tp)
	return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tg2dfilter(c,e,tp,tc)
	return c:IsSetCard(0xf40) and tc:GetOverlayGroup():IsExists(s.tg2spfilter,1,nil,e,tp)
end

function s.tg2filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e) and Duel.IsExistingMatchingCard(s.tg2dfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tg2filter(chkc,e,tp) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,0,nil,e,tp)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_OVERLAY)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if not (tg and tg:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) then return end
	local dg=Duel.GetMatchingGroup(s.tg2dfilter,tp,LOCATION_DECK,0,nil,e,tp,tg)
	if #dg==0 then return end
	local dsg=aux.SelectUnselectGroup(dg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_XMATERIAL)
	Duel.Overlay(tg,dsg,true)
	local g=tg:GetOverlayGroup():Filter(s.tg2spfilter,nil,e,tp)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end

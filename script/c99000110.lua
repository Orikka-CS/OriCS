--�������� "����"
local s,id=GetID()
function s.initial_effect(c)
	--Xyz summon
	Xyz.AddProcedure(c,nil,6,5)
	c:EnableReviveLimit()
	--�ڽ� ������ ī�� 1���� �� ī���� ������ ����� �Ѵ�.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.attachtg)
	e1:SetOperation(s.attachop)
	c:RegisterEffect(e1)
	--"No." ���� �̿���, �� ī�庸�� ��ũ�� 1�� �Ǵ� 2�� ���� ������ ���� 1����, �ڽ� �ʵ��� �� ī�� ���� ��ġ�� ������ ��ȯ���� ����Ͽ� ����Ʈ�� ������ Ư�� ��ȯ�Ѵ�.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetHintTiming(TIMING_DRAW_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--�ڽ� �ʵ��� ī�尡 ���� / ȿ���� �ı��� ���, ��ſ� �� ī���� ������ ���縦 1�� ������ �� �ִ�.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.reptg)
	e3:SetValue(function(e,_c) return s.repfilter(_c,e:GetHandlerPlayer()) end)
	c:RegisterEffect(e3)
	--�� ī�带 ����μ� ������ �ִ� ������ ���ʹ� ������ ȿ���� ��´�.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(s.reptg)
	e4:SetValue(function(e,_c) return s.repfilter(_c,e:GetHandlerPlayer()) end)
	c:RegisterEffect(e4)
end
s.listed_series={0xc22,0x95,0x48}
function s.attachfilter(c,xyzc,tp)
	return c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler(),tp) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local tc=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_GRAVE,0,1,1,nil,c,tp):GetFirst()
	if tc then
		Duel.HintSelection(tc)
		Duel.Overlay(c,tc)
	end
end
function s.costfilter(c)
	return c:IsSetCard(0xc22) or c:IsSetCard(0x95)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	local ct=#g==g:FilterCount(s.costfilter,nil) and 1
		or c:GetOverlayCount()-1
	if ct<1 then return end
	if chk==0 then return c:CheckRemoveOverlayCard(tp,ct,REASON_COST) and c:GetFlagEffect(id)==0 end
	c:RemoveOverlayCard(tp,ct,c:GetOverlayCount()-1,REASON_COST)
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.filter(c,e,tp,rk,pg)
	return (c:IsRank(rk+1) or c:IsRank(rk+2)) and not c:IsSetCard(0x48) and e:GetHandler():IsCanBeXyzMaterial(c,tp)
		and (#pg<=0 or pg:IsContains(e:GetHandler())) and Duel.GetLocationCountFromEx(tp,tp,e:GetHandler(),c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(e:GetHandler()),tp,nil,nil,REASON_XYZ)
		return #pg<=1 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler():GetRank(),pg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e) then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c:GetRank(),pg)
	local sc=g:GetFirst()
	if sc then
		sc:SetMaterial(c)
		Duel.Overlay(sc,c)
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField() and c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end
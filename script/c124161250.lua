--렉스퀴아트 제바트
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local params={extrafil=s.extrafil}
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.GetFlagEffect(tp,id)>0 end)
	e2:SetTarget(Fusion.SummonEffTG(params))
	e2:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e2)
	--count
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.cnt)
		Duel.RegisterEffect(ge1,0)
	end)
end

function s.cntfilter(c)
	return c:IsSetCard(0xf30)
end

function s.cnt(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.cntfilter,nil)
	if #g==0 then return end
	for p=0,1 do
		if g:IsExists(Card.IsControler,1,nil,p) and not (Duel.GetFlagEffect(p,id)>0) then
			Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_GRAVE)
end

function s.op1dfilter(c,tp)
	return c:IsSetCard(0xf30) and c:IsControler(tp) and c:IsAbleToDeck()
end

function s.op1filter(c,e,tp)
	return c:IsMonster() and not c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.op1con(sg,e,tp,mg)
	return sg:IsExists(s.op1dfilter,1,nil,tp)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		local g=Duel.GetMatchingGroup(s.op1dfilter,tp,LOCATION_GRAVE,0,nil,tp)
		local nx=Duel.GetMatchingGroupCount(s.op1filter,tp,LOCATION_GRAVE,0,nil,e,tp)>0
		if nx and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
			local sg=aux.SelectUnselectGroup(g,e,tp,1,3,s.op1con,1,tp,HINTMSG_TODECK)
			Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end

--effect 2
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsSetCard,1,nil,0xf30,fc,SUMMON_TYPE_FUSION,tp)
end

function s.extrafil(e,tp,mg,sumtype)
	return nil,s.fcheck
end
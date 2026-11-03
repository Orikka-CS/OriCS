--비블리오션 트라크
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp) return Duel.GetFlagEffect(tp,id)>0 end)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
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

function s.cntfilter(c,tp)
	return c:IsControler(tp) and c:IsContinuousSpell()
end
function s.cnt(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		if eg:FilterCount(s.cntfilter,nil,p)>0 and Duel.GetFlagEffect(p,id)==0 then Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1) end
	end
end

--effect 1
function s.tg1filter(c)
	return c:IsSetCard(0x6f20) and c:IsTrap() and c:IsSSetable()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if #g==0 or Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SET):GetFirst()
	if Duel.SSet(tp,sg)==0 then return end
	Duel.ShuffleDeck(tp)
	Duel.BreakEffect()
	Duel.ConfirmDecktop(tp,4)
	local dg=Duel.GetDecktopGroup(tp,4):Filter(Card.IsContinuousSpell,nil)
	if #dg>0 and Duel.SendtoGrave(dg,REASON_EFFECT)>0 and sg:IsLocation(LOCATION_SZONE) and sg:IsFacedown() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sg:RegisterEffect(e1)
	end
	Duel.ShuffleDeck(tp)
end

--effect 2
function s.con2filter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x6f20)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:FilterCount(s.con2filter,nil,tp)>0
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end

--하현의 허월상 올레포
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e1:SetTargetRange(LOCATION_EXTRA,0)
	e1:SetCondition(s.matcon)
	e1:SetTarget(function(e,c) return c:IsAbleToGrave() end)
	e1:SetValue(s.matval)
	e1:SetLabelObject({s.extrafil_replacement})
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.checkop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

function s.matcon(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id+100)==0
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not eg then return end
	local g=eg:Filter(Card.IsSummonPlayer,nil,tp):Filter(Card.IsSummonType,nil,SUMMON_TYPE_FUSION)
	if #g==0 then return end
	for tc in aux.Next(g) do
		local mat=tc:GetMaterial()
		if mat and mat:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_DECK) then
			Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
			e:Reset()
			return
		end
	end
end

function s.matval(e,c)
	return c and c:IsControler(e:GetHandlerPlayer())
end

function s.extrafil_repl_filter(c)
	return c:IsSetCard(0xf34) and c:IsMonster() and c:IsAbleToGrave()
end

function s.extrafil_replacement(e,tp,mg)
	local g=Duel.GetMatchingGroup(s.extrafil_repl_filter,tp,LOCATION_DECK,0,nil)
	return g,s.fcheck_replacement
end

function s.fcheck_replacement(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1 and sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=0
end

--effect 2
function s.con2filter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsControler(1-tp)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_FUSION+REASON_MATERIAL) and eg:FilterCount(s.con2filter,nil,tp)>0
end

function s.tg2filter(c,e,tp)
	return s.con2filter(c,tp) and c:IsLocation(LOCATION_MZONE) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.tg2filter(chkc,e,tp) and eg:IsContains(chkc) end
	local c=e:GetHandler()
	local g=eg:Filter(s.tg2filter,nil,e,tp)
	if chk==0 then return c:IsAbleToDeck() and #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg+c,2,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	if c:IsRelateToEffect(e) and #tg>0 then
		Duel.SendtoDeck(tg+c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
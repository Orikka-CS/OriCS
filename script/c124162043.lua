--비블리오션 바이블
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local params={matfilter=s.tg2filter,extrafil=s.extrafil,extraop=Fusion.BanishMaterial}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(Fusion.SummonEffTG(params))
	e2:SetOperation(s.op2(Fusion.SummonEffOP(params)))
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_DECK) end)
	e3:SetTarget(s.tg3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end

--effect 1
function s.tg1filter(c,e)
	return c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function s.tg1hfilter(c)
	return c:IsSetCard(0x6f20) and c:IsMonster() and c:IsAbleToHand()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.tg1filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_ONFIELD,0,nil,e)
	local hg=Duel.GetMatchingGroup(s.tg1hfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 and #hg>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	local hg=Duel.GetMatchingGroup(s.tg1hfilter,tp,LOCATION_DECK,0,nil)
	if #hg==0 then return end
	local hsg=aux.SelectUnselectGroup(hg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
	if Duel.SendtoHand(hsg,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,hsg)
	Duel.ShuffleDeck(tp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.DisableShuffleCheck()
		Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end

--effect 2
function s.tg2filter(c)
	return c:IsMonster() and c:IsLocation(LOCATION_HAND+LOCATION_MZONE) and c:IsAbleToRemove()
end
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsSetCard,1,nil,0x6f20,fc,SUMMON_TYPE_FUSION,tp)
end
function s.extrafil(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil),s.fcheck
end
function s.op2(fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() then fusop(e,tp,eg,ep,ev,re,r,rp) end
	end
end

--effect 3
function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not e:GetHandler():IsForbidden() end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end

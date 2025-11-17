--렉스퀴아트 퀴 베니트
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0xf30),matfilter=aux.FALSE,extrafil=s.extrafil,extraop=Fusion.ShuffleMaterial,extratg=s.extratg})
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetValue(s.val2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.extrafil(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToDeck),tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end

--effect 2
function s.tg2filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xf30) and c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() and eg:FilterCount(s.tg2filter,nil,tp)>0 end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,0))
end

function s.val2(e,c)
	return s.tg2filter(c,e:GetHandlerPlayer())
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,POS_FACEUP,REASON_EFFECT)
end
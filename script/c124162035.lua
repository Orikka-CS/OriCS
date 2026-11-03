--비블리오션 파시프
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_DECK)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1filter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE) and c:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con1filter,nil,tp)>0
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end

--effect 2
function s.cst2filter(c)
	return (c:IsSetCard(0x6f20) or c:IsContinuousSpell()) and not c:IsPublic()
end
function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONFIRM):GetFirst()
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(tp)
	sg:CreateEffectRelation(e)
	e:SetLabelObject(sg)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsPlayerCanDraw(tp,2)
	local b2=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3
	if chk==0 then return b1 or b2 end
	local b=Duel.SelectEffect(tp,{b1,aux.Stringid(id,2)},{b2,aux.Stringid(id,3)})
	e:SetLabel(b)
	if b==1 then
		e:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetLabelObject(),1,0,0)
	else
		e:SetCategory(CATEGORY_TOGRAVE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local sg=e:GetLabelObject()
	if e:GetLabel()==1 then
		if Duel.Draw(tp,2,REASON_EFFECT)>0 and sg:IsRelateToEffect(e) and sg:IsLocation(LOCATION_HAND) then Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT) end
	else
		Duel.ConfirmDecktop(tp,4)
		local g=Duel.GetDecktopGroup(tp,4):Filter(Card.IsContinuousSpell,nil)
		if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
		Duel.ShuffleDeck(tp)
	end
	sg:ReleaseEffectRelation(e)
end

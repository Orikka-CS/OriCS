--엉킨 실∞밤하늘을 닫는 날개
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetCondition(aux.exccon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.tar3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end
function s.val1(e)
	local te=e:GetLabelObject()
	te:SetLabel(1)
end
function s.cfil2(c)
	return ((c:IsLocation(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_ONFIELD) and c:IsAbleToGraveAsCost())
		or (c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemoveAsCost())) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_EFFECT)
end
function s.cfun2(sg,e,tp,mg)
	return sg:IsExists(Card.IsRace,1,nil,s.race) and sg:IsExists(Card.IsAttribute,1,nil,s.attribute)
end
function s.tfil2(c,label,g,e,tp)
	s.race=c:GetRace()
	s.attribute=c:GetAttribute()
	local res=c:IsNegatableMonster() and (label~=1 or aux.SelectUnselectGroup(g,e,tp,1,2,s.cfun2,0))
	s.race=nil
	s.attribute=nil
	return res
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local label=e:GetLabel()
	if c:IsLocation(LOCATION_HAND) and #{c:IsHasEffect(EFFECT_TRAP_ACT_IN_HAND)}==1 then
		label=1
	end
	e:SetLabel(0)
	local g=Duel.GetMatchingGroup(s.cfil2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,nil)
	if chkc then
		return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsNegatableMonster()
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tfil2,tp,0,LOCATION_MZONE,1,nil,label,g,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sg=Duel.SelectTarget(tp,s.tfil2,tp,0,LOCATION_MZONE,1,1,nil,label,g,e,tp)
	if label==1 then
		local tc=sg:GetFirst()
		s.race=tc:GetRace()
		s.attribute=tc:GetAttribute()
		local tg=aux.SelectUnselectGroup(g,e,tp,1,2,s.cfun2,1,tp,HINTMSG_TOGRAVE)
		s.race=nil
		s.attribute=nil
		local rg=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		tg:Sub(rg)
		Duel.SendtoGrave(tg,REASON_COST)
		Duel.Remove(rg,POS_FACEUP,REASON_COST)
	end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,sg,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		return
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.oval21)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.otar22)
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_MSET)
	Duel.RegisterEffect(e3,tp)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e4,tp)
end
function s.oval21(e,te)
	return te:IsActiveType(TYPE_MONSTER)
end
function s.otar22(e,c)
	return c:IsType(TYPE_EFFECT)
end
function s.tfil3(c,e)
	return c:IsFaceup() and not c:IsCode(id) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
		 and ((c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_EFFECT))
			or (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0xc06)))
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return false
	end
	local g=Duel.GetMatchingGroup(s.tfil3,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	if chk==0 then
		return #g>0 and Duel.IsPlayerCanDraw(tp,1)
	end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,4,aux.dncheck,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 or Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then
		return
	end
	local og=Duel.GetOperatedGroup()
	if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
		Duel.ShuffleDeck(tp)
	end
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
	if ct~=0 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
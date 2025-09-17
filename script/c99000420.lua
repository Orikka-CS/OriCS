--페넘브라 클로에
local s,id=GetID()
function s.initial_effect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_DECK_REVERSE_CHECK)
	--자신의 패 / 묘지에서 레벨 5 이하의 "페넘브라" 몬스터 1장을 특수 소환한다.
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_TO_HAND)
	e0:SetCountLimit(1,id)
	e0:SetCondition(function(e) return not e:GetHandler():IsReason(REASON_DRAW) end)
	e0:SetCost(s.spcost)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	--덱에서 "페넘브라" 마법 / 함정 카드 1장을 자신 필드에 세트한다.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--이 카드와 상대의 덱 맨 위의 카드를 덱에 앞면으로 넣고 셔플한다.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function(e) return e:GetHandler():IsReason(REASON_EFFECT) end)
	e3:SetTarget(s.penumbra_tg)
	e3:SetOperation(s.penumbra_op)
	c:RegisterEffect(e3)
end
s.listed_series={0xc11}
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xc11) and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	--이 턴에, 자신은 빛 / 어둠 속성 몬스터밖에 특수 소환할 수 없다(엑스트라 덱에서의 특수 소환 이외).
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and not c:IsLocation(LOCATION_EXTRA)
end
function s.setfilter(c)
	return c:IsSetCard(0xc11) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
function s.penumbra_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.penumbra_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SendtoDeck(c,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK) then
		Duel.ShuffleDeck(tp)
		c:ReverseInDeck()
		--그 카드가 덱에서 벗어났을 경우, 상대는 자신의 패 / 필드의 몬스터 1장을 뒷면 표시로 제외해야 한다.
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,4))
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_MOVE)
		e1:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_DECK) end)
		e1:SetOperation(s.penumbra_op2)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_ADJUST)
		e2:SetLabelObject(c)
		e2:SetOperation(s.sheya_check)
		Duel.RegisterEffect(e2,0)
		Duel.ConfirmDecktop(1-tp,1)
		local g=Duel.GetDecktopGroup(1-tp,1)
		if #g>0 then
			local tc=g:GetFirst()
			Duel.ShuffleDeck(1-tp)
			tc:ReverseInDeck()
			local e3=Effect.CreateEffect(c)
			e3:SetDescription(aux.Stringid(id,4))
			e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e3:SetCode(EVENT_MOVE)
			e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_DECK) end)
			e3:SetOperation(s.penumbra_op3)
			tc:RegisterEffect(e3)
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e4:SetCode(EVENT_ADJUST)
			e4:SetLabelObject(tc)
			e4:SetOperation(s.sheya_check)
			Duel.RegisterEffect(e4,0)
		end
	end
end
function s.sheya_check(e,tp,eg,ep,ev,re,r,rp)
	--[[local c=e:GetLabelObject()
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0x3fe,0x3fe,nil)
	for gc in g:Iter() do
		if c:GetFlagEffect(99000417)==0 then
			Debug.PreSetTarget(c,gc)
		else
			c:CancelCardTarget(gc)
			e:Reset()
		end
	end]]--
end
function s.penumbra_op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsPlayerAffectedByEffect(tp,30459350) or c:GetFlagEffect(99000417)~=0 then return end
	local g=Duel.GetMatchingGroup(Card.IsMonster,1-tp,LOCATION_MZONE|LOCATION_HAND,0,nil)
	if #g>0 then
		Duel.Hint(HINT_OPSELECTED,tp,e:GetDescription())
		Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local sg=g:FilterSelect(1-tp,Card.IsAbleToRemove,1,1,nil,1-tp,POS_FACEDOWN,REASON_RULE)
		Duel.HintSelection(sg)
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,PLAYER_NONE,1-tp)
	end
	c:RegisterFlagEffect(99000417,RESET_EVENT|RESETS_STANDARD,0,1)
	e:Reset()
end
function s.penumbra_op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsPlayerAffectedByEffect(tp,30459350) or c:GetFlagEffect(99000417)~=0 then return end
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_MZONE|LOCATION_HAND,0,nil)
	if #g>0 then
		Duel.Hint(HINT_OPSELECTED,tp,e:GetDescription())
		Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil,tp,POS_FACEDOWN,REASON_RULE)
		Duel.HintSelection(sg)
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,PLAYER_NONE,tp)
	end
	c:RegisterFlagEffect(99000417,RESET_EVENT|RESETS_STANDARD,0,1)
	e:Reset()
end
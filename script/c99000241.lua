--파인딩 더 미싱 오더
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--자신 필드의 몬스터를 소재로서 오더 몬스터 1장을 오더 소환한다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER)
	e2:SetCondition(function() return Duel.IsMainPhase() or Duel.IsBattlePhase() end)
	e2:SetCost(s.ordcost)
	e2:SetTarget(s.ordtg)
	e2:SetOperation(s.ordop)
	c:RegisterEffect(e2)
	--엑스트라 몬스터 존의 자신 몬스터는, 그 몬스터와 같은 세로열의 메인 몬스터 존의 몬스터로서 오더 소재로 할 수 있다.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_EXTRA_ORDER_MATERIAL)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(1,0)
	e3:SetOperation(s.op)
	e3:SetValue(s.val)
	c:RegisterEffect(e3)
end
function s.ordcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
end
function s.ordtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsOrderSummonable,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.ordop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,Card.IsOrderSummonable,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		if Duel.GetCurrentChain()==1 then
			--그 오더 소환 성공시에 상대는 카드의 효과를 발동할 수 없다.
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_CHAIN_END)
			e1:SetCountLimit(1)
			e1:SetOperation(function() Duel.SetChainLimitTillChainEnd(function(e,_rp,_tp) return _tp==_rp end) end)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
		Duel.OrderSummon(tp,tc)
	end
end
function s.op(e,tp,oc,mg)
	return Duel.GetMatchingGroup(nil,tp,LOCATION_EMZONE,0,nil)
end
function s.val(e,tp,mc,oc)
	local seq=mc:GetSequence()
	return 2*seq-9
end
--프로시저 디스오더
local s,id=GetID()
function s.initial_effect(c)
	--square summon
	aux.AddSquareProcedure(c)
	--이 카드를 포함하는 자신 필드의 몬스터를 소재로서 오더 소환을 실행한다.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.Discard())
	e1:SetTarget(s.ordertg)
	e1:SetOperation(s.orderop)
	c:RegisterEffect(e1)
	--덱에서 공격력과 수비력이 1500 이하인 몬스터 1장을 특수 소환한다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.custom_type=CUSTOMTYPE_SQUARE
s.square_mana={0x0,0x0,0x0,ATTRIBUTE_DARK,ATTRIBUTE_DARK,ATTRIBUTE_DARK}
function s.tempregister(e,tp,eg,ep,ev,re,r,rp,chk)
	--그 시기에, 엑스트라 몬스터 존의 몬스터도, 그 몬스터와 같은 세로열의 자신 메인 몬스터 존의 몬스터로서 오더 소재로 할 수 있다.
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_ORDER_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(1,0)
	e1:SetOperation(s.extraop)
	e1:SetValue(s.extraval)
	Duel.RegisterEffect(e1,tp)
	return e1
end
function s.extraop(e,tp,oc,mg)
	return Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_EMZONE,LOCATION_EMZONE,nil)
end
function s.extraval(e,tp,mc,oc)
	local seq=mc:GetSequence()
	if mc:GetControler()~=tp then
		seq=11-seq
	end
	return 2*seq-9
end
function s.ordertg(e,tp,eg,ep,ev,re,r,rp,chk)
	local e1=s.tempregister(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=Duel.IsExistingMatchingCard(Card.IsOrderSummonable,tp,LOCATION_EXTRA,0,1,nil)
		e1:Reset()
		return res
	end
	e1:Reset()
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.orderop(e,tp,eg,ep,ev,re,r,rp)
	local e1=s.tempregister(e,tp,eg,ep,ev,re,r,chk)
	local g=Duel.GetMatchingGroup(Card.IsOrderSummonable,tp,LOCATION_EXTRA,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if not sc then
			e1:Reset()
			return
		end
		Duel.OrderSummon(tp,sc)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EVENT_SPSUMMON)
		e3:SetOperation(s.resetop)
		e3:SetLabelObject(e1)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	e1:Reset()
	e:Reset()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spfilter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsDefenseBelow(1500) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		--이 효과로 특수 소환한 몬스터는 효과를 발동할 수 없다.
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3302)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
	--이 효과의 발동 후, 턴 종료시까지 서로 오더 몬스터를 특수 소환할 수 없다.
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,1)
	e1:SetTarget(function(_,c) return (c:IsCustomType(CUSTOMTYPE_ORDER) or c:IsType(TYPE_ORDER)) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
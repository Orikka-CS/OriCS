--[ Trie Elow ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetLabelObject(e1)
	e2:SetValue(function(e,c) return e:GetLabelObject():SetLabel(1) end)
	e2:SetCondition(function(e) return Duel.IsCanRemoveCounter(e:GetHandlerPlayer(),1,0,COUNTER_SPELL,3,REASON_COST) end)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
	
end

s.counter_place_list={COUNTER_SPELL}

function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then e:SetLabel(0) return true end
	if e:GetLabel()>0 then
		e:SetLabel(0)
		Duel.RemoveCounter(tp,1,0,COUNTER_SPELL,3,REASON_COST)
	end
end
function s.tar1fil(c,ft,e,tp)
	return c:IsSetCard(0x9d6f) and c:IsMonster() and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)))
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar1fil,tp,LOCATION_DECK,0,1,nil,ft,e,tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.op1fil(c)
	return c:IsFaceup() and c:IsCanAddCounter(COUNTER_SPELL,2)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.tar1fil,tp,LOCATION_DECK,0,1,1,nil,ft,e,tp):GetFirst()
	if not sc then return end
	local res=aux.ToHandOrElse(sc,tp,
		function(sc)
			return ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		end,
		function(sc)
			return Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		end,
		aux.Stringid(id,2))
	if res==1 and sc:IsLocation(LOCATION_MZONE) and sc:IsPosition(POS_FACEDOWN_DEFENSE) then Duel.ConfirmCards(1-tp,sc) end
	if res==1 and not c:IsStatus(STATUS_SET_TURN) then
		local g=Duel.SelectMatchingCard(tp,s.op1fil,tp,LOCATION_MZONE,0,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			g:GetFirst():AddCounter(COUNTER_SPELL,2)
		end
	end
	if not c:IsRelateToEffect(e) then return end
	if c:IsSSetable(true) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.BreakEffect()
		c:CancelToGrave()
		Duel.ChangePosition(c,POS_FACEDOWN)
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x9d6f) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsReason(REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

--노블레스 오블록체인 / Noblesse O'Blockchain
--Upstream contracts inspected 2026-09-22: official/c10045474.lua (hand trap),
--Card.GetColumnGroup, card.cpp destination_redirect, processor.cpp chain cleanup.
local s,id=GetID()
s.toss_coin=true
--Duel.LoadScript("blockchain.lua")
local B=Blockchain
function s.initial_effect(c)
	B.Init(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local hand=Effect.CreateEffect(c)
	hand:SetType(EFFECT_TYPE_SINGLE)
	hand:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	hand:SetCondition(function(e)
		return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0
	end)
	c:RegisterEffect(hand)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(s.zerocost)
	e2:SetOperation(s.zeroop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function() return Duel.GetCurrentChain()==2 end)
	e3:SetTarget(s.inverttg)
	e3:SetOperation(s.invertop)
	c:RegisterEffect(e3)
end
s.listed_series={0x6d72}
function s.spfilter(c,e,tp)
	return c:IsSetCard(B.SET) and c:IsRitualMonster()
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	B.Track(e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc or Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)==0 then return end
	--This is not a Ritual Summon; do not call CompleteProcedure here.
	local context=B.Context(e)
	local field_id=tc:GetFieldID()
	Duel.BreakEffect()
	local result=B.Toss(e,tp)
	if result==COIN_HEADS and context.previous_effect and tc:IsFaceup()
		and tc:IsLocation(LOCATION_MZONE) and tc:GetFieldID()==field_id then
		local immune=Effect.CreateEffect(e:GetHandler())
		immune:SetType(EFFECT_TYPE_SINGLE)
		immune:SetCode(EFFECT_IMMUNE_EFFECT)
		immune:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		immune:SetRange(LOCATION_MZONE)
		immune:SetReset(RESET_EVENT|RESETS_STANDARD)
		immune:SetValue(function(_,te)
			return te:GetOwnerPlayer()==1-tp and te:IsActivated()
		end)
		tc:RegisterEffect(immune)
	elseif result==COIN_TAILS and context.responded then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_SZONE) then
			--Only the automatic post-activation send is redirected. Destruction by
			--a lower chain link retains its own destination. Chain cleanup runs
			--before RESET_CHAIN in the inspected core.
			local redirect=Effect.CreateEffect(c)
			redirect:SetType(EFFECT_TYPE_SINGLE)
			redirect:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			redirect:SetCode(EFFECT_TO_GRAVE_REDIRECT)
			redirect:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CHAIN)
			redirect:SetValue(function(_,card,reason)
				return (reason&REASON_RULE)~=0 and card:IsStatus(STATUS_LEAVE_CONFIRMED)
					and LOCATION_HAND or 0
			end)
			c:RegisterEffect(redirect)
		end
	end
end
function s.zerocost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.columnmonster(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
		and c:IsMonster() and c:IsSetCard(B.SET)
end
function s.zerotarget(e,c)
	return c:IsFaceup() and c:GetColumnGroup():IsExists(s.columnmonster,1,nil,e:GetOwnerPlayer())
end
function s.zeroop(e,tp)
	--"This turn" creates a dynamic field effect: moving a monster or summoning
	--another Blockchain monster changes the affected columns immediately.
	local atk=Effect.CreateEffect(e:GetHandler())
	atk:SetType(EFFECT_TYPE_FIELD)
	atk:SetCode(EFFECT_SET_ATTACK_FINAL)
	atk:SetTargetRange(0,LOCATION_MZONE)
	atk:SetTarget(s.zerotarget)
	atk:SetValue(0)
	atk:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(atk,tp)
	local def=atk:Clone()
	def:SetCode(EFFECT_SET_DEFENSE_FINAL)
	Duel.RegisterEffect(def,tp)
end
function s.inverttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.invertop(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_DECK) then
		B.SetInverted(tp)
	end
end

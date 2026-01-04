--종말의 숭배자 에리스
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FIEND),1,1,Synchro.NonTunerEx(Card.IsAttribute,ATTRIBUTE_DARK),1,99)
	c:EnableReviveLimit()
	--"열흘하고도 사흘의 시간"의 턴 카운트가 6턴 이상일 경우, 이 카드는 "종말" 카드 이외의 카드의 효과를 받지 않는다.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.descon)
	e1:SetValue(function(e,te) return not (te:GetHandler():IsSetCard(0xc10) or te:GetHandler():IsCode(28985331)) end)
	c:RegisterEffect(e1)
	--대상의 카드의 효과를 무효로 하고 제외한다.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	--상대 필드의 몬스터, 상대의 패, 상대 턴에서 세어서 3턴 동안에 상대가 드로우한 카드를 전부 확인하고, 그 중에서 공격력 1500 이상의 몬스터를 전부 파괴한다.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.viruscost)
	e3:SetTarget(s.virustg)
	e3:SetOperation(s.virusop)
	c:RegisterEffect(e3)
end
s.listed_names={99000263}
s.listed_series={0xc10}
s.listed_turn_count=true
function s.descon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFlagEffect(tp,99000263)>=6 or Duel.GetFlagEffect(1-tp,99000263)>=6
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsHasEffect,tp,LOCATION_ALL,LOCATION_ALL,1,nil,1082946) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(1082946,0))
	local turn_count_g=Duel.SelectMatchingCard(tp,Card.IsHasEffect,tp,LOCATION_ALL,LOCATION_ALL,1,1,nil,1082946)
	local turn_count_tc=turn_count_g:GetFirst()
	local eff={turn_count_tc:GetCardEffect(1082946)}
	local sel={}
	local seld={}
	local turne
	for _,te in ipairs(eff) do
		table.insert(sel,te)
		table.insert(seld,te:GetDescription())
	end
	if #sel==1 then turne=sel[1] elseif #sel>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
		local op=Duel.SelectOption(tp,table.unpack(seld))+1
		turne=sel[op]
	end
	if not turne then return end
	local op=turne:GetOperation()
	op(turne,turne:GetOwnerPlayer(),nil,0,1082946,nil,0,0)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsNegatable() and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(aux.AND(Card.IsNegatable,Card.IsAbleToRemove),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,aux.AND(Card.IsNegatable,Card.IsAbleToRemove),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsNegatable() and tc:IsCanBeDisabledByEffect(e) then
		--Negate its effects
		tc:NegateEffects(e:GetHandler())
		Duel.AdjustInstantly(tc)
		if tc:IsDisabled() then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function s.costfilter(c)
	return c:IsLevelAbove(6) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.viruscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil)
	Duel.Release(g,REASON_COST)
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(1500)
end
function s.virustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.filter(c)
	return c:IsMonster() and c:IsAttackAbove(1500)
end
function s.virusop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local conf=Duel.GetFieldGroup(tp,0,LOCATION_MZONE|LOCATION_HAND)
	if #conf>0 then
		Duel.ConfirmCards(tp,conf)
		local dg=conf:Filter(s.filter,nil)
		Duel.Destroy(dg,REASON_EFFECT)
		Duel.ShuffleHand(1-tp)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DRAW)
	e1:SetOperation(s.desop)
	e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,3)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(s.turncon)
	e2:SetOperation(s.turnop)
	e2:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,3)
	Duel.RegisterEffect(e2,tp)
	e2:SetLabelObject(e1)
	local descnum=tp==c:GetOwner() and 0 or 1
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetDescription(aux.Stringid(4931121,descnum))
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(1082946)
	e3:SetLabelObject(e2)
	e3:SetOwnerPlayer(tp)
	e3:SetOperation(s.reset)
	e3:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,3)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,3)
	e4:SetTargetRange(0,1)
	Duel.RegisterEffect(e4,tp)
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	s.turnop(e:GetLabelObject(),tp,eg,ep,ev,e,r,rp)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if ep==e:GetOwnerPlayer() then return end
	local hg=eg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if #hg==0 then return end
	Duel.ConfirmCards(1-ep,hg)
	local dg=hg:Filter(s.filter,nil)
	Duel.Destroy(dg,REASON_EFFECT)
	Duel.ShuffleHand(ep)
end
function s.turncon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp)
end
function s.turnop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct+1
	e:SetLabel(ct)
	e:GetHandler():SetTurnCounter(ct)
	if ct==3 then
		e:GetLabelObject():Reset()
		if re then re:Reset() end
	end
end
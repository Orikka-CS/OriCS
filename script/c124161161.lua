--Hypalte Elysion
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(_,c) return c:IsSetCard(0xf2a) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--effect 2
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.con2)
	e3:SetTarget(s.tg2)
	e3:SetOperation(s.op2)
	c:RegisterEffect(e3)
	--effect 3
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTarget(s.tg3)
	e4:SetValue(s.val3)
	c:RegisterEffect(e4)
end

--effect 1
function s.val1filter(c)
	return c:IsFacedown()
end

function s.val1(e,c)
	return Duel.GetMatchingGroupCount(s.val1filter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)*300
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_ONFIELD,0,nil)
	return g>0
end

function s.tg2filter(c,e,tp)
	return c:IsSetCard(0xf2a) and ((c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) or (c:IsSpellTrap() and not c:IsType(TYPE_FIELD) and c:IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0))
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_HAND,0,nil,e,tp)
	if chk==0 then return #g>0 and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_HAND,0,nil,e,tp)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SET):GetFirst()
	if sg:IsMonster() then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	else
		Duel.SSet(tp,sg)
	end
	Duel.Draw(tp,1,REASON_EFFECT)
end

--effect 3
function s.tg3(e,c)
	local tp=e:GetHandlerPlayer()
	return c:IsFacedown() and (c:IsControler(1-tp) or c:GetOverlayCount()>0) 
end

function s.val3(e,te)
	return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActivated()
end
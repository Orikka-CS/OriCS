--휴프알로 엘리시온
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
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf2a) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTarget(s.tg3)
	e3:SetValue(s.val3)
	c:RegisterEffect(e3)
	--count
	aux.GlobalCheck(s,function()
		local cnt=Effect.CreateEffect(c)
		cnt:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		cnt:SetCode(EVENT_FLIP)
		cnt:SetOperation(s.cnt)
		Duel.RegisterEffect(cnt,0)
	end)
end

--count
function s.cnt(e,tp,eg,ep,ev,re,r,rp)
	for tc in eg:Iter() do
		if tc:IsFaceup() then tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1) end
	end
end

--effect 1
function s.val1filter(c)
	return c:IsType(TYPE_XYZ) and (c:IsFacedown() or c:GetFlagEffect(id)>0)
end

function s.val1(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.val1filter,tp,LOCATION_MZONE,0,nil)
	local x=0
	if #g==0 then return 0 end
	for tc in aux.Next(g) do
		x=x+tc:GetOverlayCount()
	end
	return x*100
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
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_HAND,0,nil,e,tp)
	if chk==0 then return #g>0 and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_HAND,0,nil,e,tp)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SET):GetFirst()
	if sg:IsMonster() then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		Duel.ConfirmCards(1-tp,sg)
	else
		Duel.SSet(tp,sg)
	end
	Duel.Draw(tp,1,REASON_EFFECT)
end

--effect 3
function s.tg3(e,c)
	return c:IsFacedown()
end

function s.val3(e,te)
	return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActivated() and te:IsActiveType(TYPE_SPELL)
end
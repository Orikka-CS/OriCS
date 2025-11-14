--체어라키 쓰론
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
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf32) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.con3)
	e3:SetTarget(s.tg3)
	c:RegisterEffect(e3)
	--count
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.cnt)
		Duel.RegisterEffect(ge1,0)
	end)
end

--count
function s.cnt(e,tp,eg,ep,ev,re,r,rp)
	if not (re and re:IsActiveType(TYPE_TRAP)) then return end
	for tc in eg:Iter() do
		if tc:IsType(TYPE_XYZ) then
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET,0,1)
		end
	end
end

--effect 1
function s.val1filter(c)
	return c:IsFaceup() and c:GetFlagEffect(id)>0
end

function s.val1(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.val1filter,tp,LOCATION_MZONE,0,nil)
	local ct=0
	for tc in aux.Next(g) do
		ct=ct+tc:GetRank()
	end
	return ct*100
end

--effect 2
function s.con2filter(c,tp,re)
	return c:IsControler(tp) and re and re:IsActiveType(TYPE_TRAP) and c:IsFaceup() and c:IsType(TYPE_XYZ)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,tp,re)>0
end

function s.tg2filter(c,e)
	return c:IsSetCard(0xf32) and not c:IsType(TYPE_FIELD) and c:IsCanBeEffectTarget(e) and c:IsAbleToHand()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end

function s.op2filter(c)
	return c:IsAbleToChangeControler()
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg then
		local g=Duel.GetMatchingGroup(s.op2filter,tp,0,LOCATION_MZONE,nil)
		if Duel.SendtoHand(tg,nil,REASON_EFFECT)>0 and tg:IsAbleToRemove() and #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
			local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONTROL)
			Duel.GetControl(sg,tp)
		end
	end
end

--effect 3
function s.con3filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf32) and c:IsType(TYPE_XYZ)
end

function s.con3(e)
	return Duel.GetMatchingGroupCount(s.con3filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)>0
end

function s.tg3(e,c,sump,sumtype,sumpos,targetp,se)
	return se:IsSpellEffect() and se:IsHasType(EFFECT_TYPE_ACTIONS) and c:IsMonster()
end
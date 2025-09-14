--정결하고도 고혹적인 클라랑슈
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
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf2d) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
	--count
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(s.cnt)
		Duel.RegisterEffect(ge1,0)
	end)
end

--count
function s.cntfilter(c)
	return not c:IsType(TYPE_EFFECT)
end

function s.cnt(e,c)
	local g=c:GetMaterial()
	local ct=g:FilterCount(s.cntfilter,nil)
	if c:IsType(TYPE_LINK) and ct>0 then
		for i=1,ct do
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
		end
	end
end

--effect 1
function s.val1(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_LINK)
	local x=0
	for tc in aux.Next(g) do
		x=x+tc:GetFlagEffect(id)
	end
	return x*100
end

--effect 2
function s.cst2filter(c)
	return c:IsSetCard(0xf2d) and c:IsFaceup() and not c:IsType(TYPE_FIELD) and c:IsAbleToDeckOrExtraAsCost()
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,124161200,0xf2d,TYPES_TOKEN,0,0,1,RACE_REPTILE,ATTRIBUTE_WIND) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,124161200,0xf2d,TYPES_TOKEN,0,0,1,RACE_REPTILE,ATTRIBUTE_WIND) then return end
	local token=Duel.CreateToken(tp,124161200)
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end

--effect 3
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:GetFlagEffect(id)>0 and re:IsActiveType(TYPE_MONSTER) and re:GetOwnerPlayer()==tp then
		Duel.SetChainLimit(function(e,ep,tp) return ep==tp or not e:IsActiveType(TYPE_MONSTER) end)
	end
end
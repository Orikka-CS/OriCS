--엔비램블 스파이어
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
	e1:SetTarget(s.tg1)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.tg3)
	e3:SetValue(s.sumlimit)
	c:RegisterEffect(e3)
	local e3a=e3:Clone()
	e3a:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	e3a:SetValue(s.rellimit)
	c:RegisterEffect(e3a)
	local e3b=e3:Clone()
	e3b:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3b:SetValue(s.matlimit)
	c:RegisterEffect(e3b)
	local e3c=e3:Clone()
	e3c:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e3c:SetValue(s.matlimit)
	c:RegisterEffect(e3c)
	local e3d=e3:Clone()
	e3d:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e3d:SetValue(s.matlimit)
	c:RegisterEffect(e3d)
	local e3e=e3:Clone()
	e3e:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e3e:SetValue(s.matlimit)
	c:RegisterEffect(e3e)
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
function s.cntfilter(c,tp)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE)
end

function s.cnt(e,c)
	local g=c:GetMaterial()
	local tp=c:GetControler()
	local ct=g:FilterCount(s.cntfilter,nil,tp)
	if c:IsType(TYPE_LINK) and ct>0 then
		for i=1,ct do
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
		end
	end
end

--effect 1
function s.tg1(e,c)
	return c:IsSetCard(0xf3f) and c:IsMonster() and c:IsFaceup()
end

function s.val1(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_LINK)
	local ct=0
	for tc in g:Iter() do
		ct=ct+tc:GetFlagEffect(id)
	end
	return ct*300
end

--effect 2
function s.tg2filter(c,e,tp)
	if not (c:IsSetCard(0xf3f) and c:IsFaceup() and c:GetOwner()==tp and not c:IsType(TYPE_FIELD) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)) then return false end
	if c:IsControler(1-tp) then
		return Duel.IsPlayerCanDraw(tp,1)
	else
		return Duel.IsExistingMatchingCard(s.op2filter,tp,0,LOCATION_ONFIELD,1,c)
	end
end

function s.op2filter(c)
	return c:IsAbleToHand()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.tg2filter(chkc,e,tp) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e,tp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_RTOHAND)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
	if sg:GetFirst():IsControler(1-tp) then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
	end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if not tg then return end
	if tg:IsControler(1-tp) then
		if Duel.IsPlayerCanDraw(tp,1) then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	else
		local g=Duel.GetMatchingGroup(s.op2filter,tp,0,LOCATION_ONFIELD,tg)
		if #g>0 then
			local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_RTOHAND)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end

--effect 3
function s.tg3(e,c)
	return c:IsSetCard(0xf3f) and c:IsMonster() and c:IsFaceup()
end

function s.sumlimit(e,c)
	return c and c:GetControler()==1-e:GetHandlerPlayer()
end

function s.rellimit(e,re,rp)
	return rp==1-e:GetHandlerPlayer()
end

function s.matlimit(e,c)
	return c and c:GetControler()==1-e:GetHandlerPlayer()
end
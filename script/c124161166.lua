--Hypalte Insomnia
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.con2)
	e2:SetTargetRange(0,1)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
end

--effect 1
function s.cst1filter(c)
	return c:IsFacedown() and c:IsType(TYPE_XYZ)
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Group.CreateGroup()
	local xg=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(xg) do
		g:Merge(tc:GetOverlayGroup())
	end
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVEXYZ)
	Duel.SendtoGrave(sg,REASON_COST)
end

function s.tg1filter(c,e)
	return c:IsFaceup() and c:IsAbleToChangeControler() and c:IsCanBeEffectTarget(e)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_MZONE,nil,e)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tg1filter(chkc,e) end
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONTROL)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,sg,1,tp,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetFirstTarget()
	if tg:IsRelateToEffect(e) then
		Duel.GetControl(tg,tp)
	end
end

--effect 2
function s.con2filter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:IsSetCard(0xf2a)
end

function s.con2(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetMatchingGroupCount(s.con2filter,tp,LOCATION_MZONE,0,nil)>0 and Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_MZONE,nil)==0
end

function s.val2(e,re,tp)
	return re:GetActivateLocation()==LOCATION_MZONE  
end
--Unendal Vargr Fenrir
local s,id=GetID()
function s.initial_effect(c)
	--xyz
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,4,2,nil,nil,99)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_EQUIP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end

--effect 1
function s.con1()
	return Duel.IsMainPhase()
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end

function s.tg1ffilter(c,tp)
	return c:IsCode(124161058) and c:IsFaceup() and c:IsControler(tp)
end

function s.tg1filter(c,tp)
	return c:GetEquipGroup():IsExists(s.tg1ffilter,1,nil,tp)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler(),tp)
	if chk==0 then return #g>0 end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler(),tp)
	local eq=Duel.GetMatchingGroup(s.tg1ffilter,tp,LOCATION_SZONE,0,nil,tp):GetFirst()
	if #g>0 and c:IsRelateToEffect(e) then
		if Duel.Equip(tp,eq,c) then
			Duel.Overlay(c,g,true)
		end
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsCode(124161058) and c:IsControler(tp)
end

function s.con2(e,tp,eg)
	return eg:IsExists(s.con2filter,1,nil,tp)
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.tg2filter(c,e,tp)
	return c:IsCanBeEffectTarget(e)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetFirstTarget()
	if sg:IsRelateToEffect(e) then
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
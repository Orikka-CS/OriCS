--볼틱갭츠 아스타로트 맥스웰
local s,id=GetID()
function s.initial_effect(c)
	--link
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.linkfilter,2,2)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
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
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.con2)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
end

--link
function s.linkfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_LINK,scard,sumtype,tp) and c:IsSetCard(0xf37,scard,sumtype,tp)
end

--effect 1
function s.cst1filter(c)
	return c:IsSetCard(0xf37) and c:IsMonster() and c:IsAttackAbove(1) and not c:IsPublic()
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONFIRM):GetFirst()
	Duel.ConfirmCards(1-tp,sg)
	e:SetLabel(sg:GetBaseAttack())
	Duel.ShuffleHand(tp)
end

function s.tg1filter(c)
	return c:IsFaceup() and c:IsLinked()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_MZONE)
end

function s.op1dfilter(c)
	return c:IsFaceup() and c:IsAbleToDeck()
end

function s.op1rescon(sg,e,tp,mg)
	return sg:GetSum(Card.GetAttack)<=e:GetLabel()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		local mg,val=g:GetMaxGroup(Card.GetAttack)
		local sg
		if #mg>1 then
			sg=aux.SelectUnselectGroup(mg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATKDEF):GetFirst()
		else
			sg=mg:GetFirst()
		end
		if sg then
			local atk=e:GetLabel()
			sg:UpdateAttack(atk,nil,e:GetHandler())
		end
	end
	local lg=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #lg<2 then return end
	local _,max=lg:GetMaxGroup(Card.GetAttack)
	local _,min=lg:GetMinGroup(Card.GetAttack)
	local diff=max-min
	local dg=Duel.GetMatchingGroup(s.op1dfilter,tp,0,LOCATION_MZONE,nil)
	if #dg>0 and diff>0 and dg:IsExists(function(c) return c:GetAttack()<=diff end,1,nil) 
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		e:SetLabel(diff)
		local sg=aux.SelectUnselectGroup(dg,e,tp,1,#dg,s.op1rescon,1,tp,HINTMSG_TODECK)
		if #sg>0 then
			Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end

--effect 2
function s.con2filter(c)
	return c:IsFaceup() and c:IsLinked() and c:GetAttack()==0
end

function s.con2(e)
	local g=Duel.GetMatchingGroupCount(s.con2filter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)
	return g>0
end

function s.val2(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()~=LOCATION_MZONE
end
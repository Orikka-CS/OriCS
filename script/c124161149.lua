--제르디알 설퍼레인
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c)
	return c:IsSetCard(0xf29) and c:IsMonster() and not c:IsPublic()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_HAND,0,nil)
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #cg>0 and #dg>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local cg=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_HAND,0,nil)
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if #cg>0 and #dg>0 then
		local csg=aux.SelectUnselectGroup(cg,e,tp,1,#dg,aux.dncheck,1,tp,HINTMSG_CONFIRM)
		Duel.ConfirmCards(1-tp,csg)
		Duel.ShuffleHand(tp)
		local dsg=aux.SelectUnselectGroup(dg,e,tp,#csg,#csg,aux.TRUE,1,tp,HINTMSG_DESTROY)
		Duel.Destroy(dsg,REASON_EFFECT)
		Duel.BreakEffect()
		local dam=Duel.GetOperatedGroup():GetSum(Card.GetBaseAttack)
		if dam==0 then return end
		Duel.Damage(1-tp,dam//2,REASON_EFFECT)
	end
end

--effect 2
function s.con2filter(c,e,tp)
	return c:IsSetCard(0xf29) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsCanBeEffectTarget(e) and c:GetBaseAttack()>0
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,e,tp)>0
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.con2filter(chkc,e,tp) end
	local g=eg:Filter(s.con2filter,nil,e,tp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetFirstTarget()
	if tg:IsRelateToEffect(e) then
		Duel.Damage(1-tp,tg:GetBaseAttack()//2,REASON_EFFECT)
		local g=Duel.GetFieldGroup(tp,0,LOCATION_SZONE)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DESTROY)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
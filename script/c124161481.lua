--엔비램블 킬러 카인
local s,id=GetID()
function s.initial_effect(c)
	--link
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,2,s.linkfilter)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.cnt)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
end

--link
function s.linkfilter(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0xf3f,lc,sumtype,tp)
end

function s.cntfilter(c,tp)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE)
end

function s.cnt(e,c)
	local g=c:GetMaterial()
	local tp=c:GetControler()
	if g:IsExists(s.cntfilter,1,nil,tp) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
	end
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and rc:IsRelateToEffect(re) and rc:IsDestructable(e)
end

function s.tg1filter(c)
	return c:IsAbleToRemove()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_GRAVE,nil)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,0,0)
	if e:GetHandler():GetFlagEffect(id)>0 and #g>0 then
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
	end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and Duel.Destroy(rc,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_GRAVE,nil)
		if e:GetHandler():GetFlagEffect(id)>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE)
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end

--effect 2
function s.val2filter(c)
	return c:IsSetCard(0xf3f) and c:IsFaceup()
end

function s.val2(e,c)
	local g=Duel.GetMatchingGroupCount(s.val2filter,c:GetControler(),LOCATION_ONFIELD,0,c)
	return g*500
end
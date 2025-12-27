--폴루스턴 케미컬밤
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_LVCHANGE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.con1filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf36)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_MZONE,0,nil)
	return g>0
end

function s.tg1cfilter(c)
	return c:IsFaceup() and c:GetLevel()<c:GetOriginalLevel()
end

function s.tg1filter(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsAbleToRemove()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and s.tg1filter(chkc,e) end
	local ct=Duel.GetMatchingGroupCount(s.tg1cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return ct>0 and #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.TRUE,1,tp,HINTMSG_REMOVE)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0xf36)
end

function s.con2(e,tp,eg)
	return eg:FilterCount(s.con2filter,nil,tp)>0
end

function s.tg2filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf36) and c:IsLevelAbove(2)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,0,nil)
	if #g>0 then
		for tc in g:Iter() do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(-1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		Duel.Damage(1-tp,#g*500,REASON_EFFECT)
	end
end
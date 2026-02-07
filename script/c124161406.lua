--아토뮬베이릿 리무부텐
local s,id=GetID()
function s.initial_effect(c)
	--fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf3a),s.mfilter)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetCondition(s.con1)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--fusion
function s.mfilter(c,sc,st,tp)
	if not c:IsType(TYPE_EFFECT) then return false end
	local effs={c:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:IsHasCategory(CATEGORY_DESTROY) or eff:IsHasCategory(CATEGORY_REMOVE) then
			return true
		end
	end
	return false 
end

--effect 1
function s.con1filter(c,tp)
	return c:IsControler(1-tp)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con1filter,nil,tp)>0
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.op1filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsMonster()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.op1filter,tp,LOCATION_REMOVED,0,nil)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ct+1,aux.TRUE,1,tp,HINTMSG_DESTROY)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsControler(1-tp)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,tp)>0
end

function s.tg2filter(c,e)
	return c:IsAbleToRemove() and c:IsCanBeEffectTarget(e)
end

function s.tg2cfilter(c,e)
	return c:IsAbleToRemove() and c:IsCanBeEffectTarget(e) and c:IsSetCard(0xf3a)
end

function s.tg2confilter(c,tp)
	return c:IsSetCard(0xf3a) and c:IsControler(tp) 
end

function s.tg2con(sg,e,tp,mg)
	return sg:IsExists(s.tg2confilter,1,nil,tp)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.tg2filter(chkc,e) end
	local ct=Duel.GetMatchingGroupCount(s.tg2cfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return ct>0 end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,3,s.tg2con,1,tp,HINTMSG_REMOVE)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e) --
	if #tg>0 then
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
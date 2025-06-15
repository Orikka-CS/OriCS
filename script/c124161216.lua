--란샤르드 시아
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0xf2e)}
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function() return Duel.IsMainPhase() end)
	e2:SetTarget(Fusion.SummonEffTG(params))
	e2:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e2)
end

--effect 1
function s.con1filter(c,tp)
	return c:IsControler(1-tp) and c:GetOwner()==tp and c:IsSetCard(0xf2e) and not c:IsReason(REASON_DRAW)
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.con1filter,1,nil,tp)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	if c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_HAND) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,LOCATION_HAND) 
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_GRAVE)
end

function s.op1filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf2e)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		local g=Duel.GetMatchingGroup(s.op1filter,tp,LOCATION_ONFIELD,0,nil)
		local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
		if e:GetLabel()==1 and #g>0 and #rg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local rsg=aux.SelectUnselectGroup(rg,e,tp,1,#g,aux.TRUE,1,tp,HINTMSG_REMOVE)
			Duel.Remove(rsg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
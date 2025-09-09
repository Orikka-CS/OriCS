--란샤르드 스티그마
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local params=({handler=c,extrafil=s.extrafil,extratg=s.extratg})
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1(Fusion.SummonEffTG(params),Fusion.SummonEffOP(params)))
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.cst1filter(c,tp)
	return c:IsSetCard(0xf2e) and c:IsAbleToGraveAsCost() and c:GetOwner()==tp
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_HAND,0,c,tp)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(sg,REASON_COST)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,nil)
	if chk==0 then return #g>0 end
end

function s.op1(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local g=Duel.GetMatchingGroup(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,nil)
		if #g>0 then
			Duel.ConfirmCards(tp,g)
			if fustg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.BreakEffect()
				fusop(e,tp,eg,ep,ev,re,r,rp)
			end
			Duel.ShuffleHand(1-tp)
		end
	end
end

function s.ffilter(c,tp)
	return c:GetOwner()==tp
end

function s.f2filter(c,tp)
	return c:IsLocation(LOCATION_HAND) and c:IsControler(1-tp)
end

function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsSetCard,nil,0xf2e)>0 and sg:FilterCount(s.f2filter,nil,tp)<=Duel.GetMatchingGroupCount(s.ffilter,tp,0,LOCATION_HAND,nil,tp)
end

function s.extrafil(e,tp,mg)
	local sg=nil
	if Duel.GetMatchingGroupCount(s.ffilter,tp,0,LOCATION_HAND,nil,tp)>0 then
		sg=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,0,LOCATION_HAND,nil)
	end
	return sg,s.fcheck
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
end

--effect 2
function s.con2filter(c,tp)
	return c:IsControler(tp) and c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_HAND)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.con2filter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,LOCATION_GRAVE)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
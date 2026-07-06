--페를라렌트 브랑카
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local params={extrafil=s.extrafil}
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_EQUIP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1(Fusion.SummonEffTG(params),Fusion.SummonEffOP(params)))
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1eqfilter(c,tp,tc)
	return c:GetEquipTarget()==tc and tc:IsControler(1-tp)
end

function s.tg1filter(c,tp,eg)
	return c:IsFaceup() and eg:IsExists(s.tg1eqfilter,1,nil,tp,c)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_MZONE,nil,tp,eg)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.fcheckfilter(c)
	return c:GetFlagEffect(id)>0
end

function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsSetCard,1,nil,0xf41,fc,SUMMON_TYPE_FUSION,tp) and sg:IsExists(s.fcheckfilter,1,nil)
end

function s.extrafilter(c)
	return c:IsFaceup() and c:GetFlagEffect(id)>0
end

function s.extrafil(e,tp,mg,sumtype)
	return Duel.GetMatchingGroup(s.extrafilter,tp,0,LOCATION_MZONE,nil),s.fcheck
end

function s.op1(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_MZONE,nil,tp,eg)
		if #g>0 then
			for tc in g:Iter() do
				tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
			end
			if fustg(e,tp,eg,ep,ev,re,r,rp,0) then
				fusop(e,tp,eg,ep,ev,re,r,rp)
			end
			for tc in g:Iter() do
				tc:ResetFlagEffect(id)
			end
		end
	end
end

--effect 2
function s.con2filter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_SZONE) and c:IsSpell() and c:IsType(TYPE_EQUIP) and c:IsReason(REASON_DESTROY)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,tp)>0 and not eg:IsContains(e:GetHandler())
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
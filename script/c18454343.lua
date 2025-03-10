--엉킨 실∞무의식이 갇힌 그릇
local s,id=GetID()
function s.initial_effect(c)
	Ritual.AddProcEqual({handler=c,
		filter=s.tfil11,
		lv=s.pval1,
		matfilter=s.tfil12,
		location=LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,
		requirementfunc=s.pval1,
		extrafil=s.pmg1,
		extraop=s.pop1})
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
s.listed_names={18454341,18454342}
function s.pval1(c)
	return 1
end
function s.tfil11(c)
	return c:IsCode(18454342)
end
function s.tfil12(c)
	return c:IsCode(18454341)
end
function s.pmgfil1(c)
	return c:IsCode(18454341) and c:IsReleasableByEffect()
end
function s.pmg1(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.pmgfil1,tp,LOCATION_DECK,0,nil)
end
function s.pop1(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local c=e:GetHandler()
	local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
	mat:Sub(mat2)
	Duel.ReleaseRitualMaterial(mat)
	Duel.SendtoGrave(mat2,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL|REASON_RELEASE)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(3061)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	e1:SetValue(aux.tgoval)
	tc:RegisterEffect(e1,true)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetDescription(3066)
	e2:SetValue(aux.indoval)
	tc:RegisterEffect(e2,true)
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		return
	end
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetValue(s.poval13)
	Duel.RegisterEffect(e3,tp)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetTarget(s.potar14)
	Duel.RegisterEffect(e4,tp)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_MSET)
	Duel.RegisterEffect(e5,tp)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e6,tp)
end
function s.poval13(e,te)
	return te:IsActiveType(TYPE_MONSTER)
end
function s.potar14(e,c)
	return c:IsType(TYPE_EFFECT)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsAbleToEnterBP()
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BP_TWICE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetCondition(s.ocon21)
	Duel.RegisterEffect(e1,tp)
end
function s.onfil21(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
function s.ocon21(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IsExistingMatchingCard(s.onfil21,tp,LOCATION_MZONE,0,1,nil)
end
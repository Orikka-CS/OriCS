--론리 월드
local s,id=GetID()
function s.initial_effect(c)
	c:EnableUnsummonable()
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"FTo","HG")
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCL(1,id)
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"Qo","M")
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetCL(1,{id,1})
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)
end
function s.val1(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
function s.nfil2(c,tp)
	return c:GetSummonPlayer()==tp and c:IsType(TYPE_TUNER) and c:IsFaceup()
		and c:IsLevelAbove(7) and not c:IsSummonableCard()
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.nfil2,1,nil,tp)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_REMOVE_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(TYPE_TUNER)
		c:RegisterEffect(e1)
		Duel.SpecialSummonComplete()
	end
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and not c:IsStatus(STATUS_BATTLE_DESTROYED)
		and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and Duel.IsChainNegatable(ev)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SPOI(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) then
		Duel.SPOI(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if not c:IsRelateToEffect(e) and Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
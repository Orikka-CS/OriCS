--[ Insomnia ]
local s,id=GetID()
function s.initial_effect(c)

	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(POS_FACEUP)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_HAND,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_MONSTER))
	e4:SetCondition(s.con4)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	
	local e1=MakeEff(c,"Qo","M")
	e1:SetD(id,0)
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCL(1,id)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"FTo","G")
	e2:SetD(id,3)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
	
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if r&REASON_EFFECT~=0 or r&REASON_BATTLE~=0 then
		Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,1)
	end
end

function s.matfilter(c,lc,sumtype,tp)
	return c:IsLevelAbove(6) and c:IsRace(RACE_ZOMBIE,lc,sumtype,tp)
end

function s.con4(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)~=0
end

function s.cost1fil(c,g,e)
	return g:IsContains(c) or c==e:GetHandler()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	local co=Duel.CheckReleaseGroupCost(tp,s.cost1fil,1,false,nil,nil,lg,e)
	if chk==0 then return co or not c:IsRace(RACE_SPELLCASTER) end
	if not co or (not c:IsRace(RACE_SPELLCASTER) and Duel.SelectYesNo(tp,aux.Stringid(99970478,2))) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_SPELLCASTER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	else
		local g=Duel.SelectReleaseGroupCost(tp,s.cost1fil,1,1,false,nil,nil,lg,e)
		Duel.Release(g,REASON_COST)
	end
end
function s.tar1fil(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsSummonable(true,nil)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar1fil,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.tar1fil,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and ev>=2000
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end

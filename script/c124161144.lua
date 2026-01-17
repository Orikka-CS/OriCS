--제르디알의 영도사
local s,id=GetID()
function s.initial_effect(c)
	--synchro
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,s.tfilter,1,1,Synchro.NonTuner(nil),1,99)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return Duel.IsMainPhase() end)
	e2:SetCost(Cost.PayLP(700))
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--synchro
s.material={124161139}
s.listed_names={124161139}
function s.tfilter(c,lc,stype,tp)
	return c:IsSummonCode(lc,stype,tp,124161139)
end

--effect 1
function s.tg1filter(c)
	return c:IsSpellTrap() and c:IsSetCard(0xf29) and c:IsSSetable()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and #g>0 end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SET):GetFirst()
		Duel.SSet(tp,sg)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		if sg:IsQuickPlaySpell() then
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		elseif sg:IsTrap() then
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		end
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sg:RegisterEffect(e1)
	end
end

--effect 2
function s.tg2filter(c)
	return c:IsSetCard(0xf29) and c:IsMonster() and not c:IsPublic()
end

function s.tg2ffilter(c,n)
	return c:IsAbleToChangeControler() and c:IsFaceup() and c:GetAttack()<700*n
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_HAND,0,nil)
	local n=g:GetClassCount(Card.GetCode)
	if n>5 then n=5 end
	local cg=Duel.GetMatchingGroup(s.tg2ffilter,tp,0,LOCATION_MZONE,nil,n)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 and #cg>0 end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,tp,0)
end

function s.op2check(sg,e,tp,mg)
	return aux.dncheck(sg,e,tp,mg) and Duel.IsExistingMatchingCard(s.tg2ffilter,tp,0,LOCATION_MZONE,1,nil,#sg)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_HAND,0,nil)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,5,s.op2check,1,tp,HINTMSG_CONFIRM)
	if #sg>0 then
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleHand(tp)
		local n=#sg
		local cg=Duel.GetMatchingGroup(s.tg2ffilter,tp,0,LOCATION_MZONE,nil,n)
		if #cg>0 then
			local csg=aux.SelectUnselectGroup(cg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONTROL)
			Duel.GetControl(csg,tp)
		end
	end
end
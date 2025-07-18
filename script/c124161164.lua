--휴프알로 시에스타
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=6 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.op1filter(c,e,tp)
	return c:IsSetCard(0xf2a) and ((c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) or (c:IsSpellTrap() and c:IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0))
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local ac=6
	Duel.ConfirmDecktop(tp,ac)
	local g=Duel.GetDecktopGroup(tp,ac)
	g=g:Filter(s.op1filter,nil,e,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then	
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SET):GetFirst()
		Duel.DisableShuffleCheck()
		if sg:IsMonster() then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		else
			Duel.SSet(tp,sg)
		end
		ac=ac-1
	end
	if ac>0 then
		Duel.SortDecktop(tp,tp,ac)
	end
end

--effect 2
function s.con2filter(c)
	return c:IsSetCard(0xf2a)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(s.con2filter,tp,LOCATION_GRAVE,0,nil)>0
end

function s.tg2filter(c,e)
	return c:IsCanBeEffectTarget(e) and ((c:IsFaceup() and c:IsCanTurnSet()) or c:IsFacedown())
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_POSCHANGE)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg then
		if tg:IsFaceup() and tg:IsCanTurnSet() then
			Duel.ChangePosition(tg,POS_FACEDOWN_DEFENSE)
		else
			Duel.ChangePosition(tg,POS_FACEUP_DEFENSE)
		end
	end
end
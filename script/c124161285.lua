--체어라키 커널 스베르타르
local s,id=GetID()
function s.initial_effect(c)
	--xyz
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf32),6,3)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.DetachFromSelf(1,1,nil))
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id)>0 end)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--count
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.cnt)
		Duel.RegisterEffect(ge1,0)
	end)
end

--count
function s.cnt(e,tp,eg,ep,ev,re,r,rp)
	if not (re and re:IsActiveType(TYPE_TRAP)) then return end
	for tc in eg:Iter() do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET,0,1)
	end
end

--effect 1
function s.tg1ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf32) and c:IsTrap()
end

function s.tg1filter(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsMonster()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and s.tg1filter(chkc,e) end
	local ct=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),Duel.GetMatchingGroup(s.tg1ctfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil):GetClassCount(Card.GetCode))
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,e:GetHandler(),e)
	if chk==0 then return ct>0 and #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.TRUE,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	tg=tg-tg:Filter(Card.IsImmuneToEffect,nil,e)
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if #tg>0 then
		if #tg>ct then
			local gg=aux.SelectUnselectGroup(tg,e,tp,#tg-ct,#tg-ct,aux.TRUE,1,tp,HINTMSG_TOGRAVE)
			Duel.SendtoGrave(gg,REASON_RULE,nil,PLAYER_NONE)
			tg=tg-gg
		end
		for tc in tg:Iter() do
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
			e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
			tc:RegisterEffect(e1)
			if tc:IsMonsterCard() then
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
				e2:SetType(EFFECT_TYPE_QUICK_O)
				e2:SetCode(EVENT_FREE_CHAIN)
				e2:SetRange(LOCATION_SZONE)
				e2:SetCountLimit(1)
				e2:SetTarget(s.op1tg)
				e2:SetOperation(s.op1op)
				e2:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
				tc:RegisterEffect(e2)
			end
		end
	end
end

function s.op1tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.op1op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

--effect 2
function s.tg2filter(c,e)
	return c:IsTrap() and c:IsSSetable() and c:IsCanBeEffectTarget(e) and c:IsFaceup()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tg2filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_REMOVED,0,nil,e)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SET):GetFirst()
	Duel.SetTargetCard(sg)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if tg and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.SSet(tp,tg)
	end
end
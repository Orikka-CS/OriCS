--패스 체어라키
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1filter(c)
	return c:IsSetCard(0xf32) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.op1filter(c)
	return c:IsSetCard(0xf32) and c:IsMonster()
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		local cg=Duel.GetMatchingGroup(s.op1filter,tp,LOCATION_HAND+LOCATION_REMOVED,0,sg)
		if #cg>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			local csg=aux.SelectUnselectGroup(cg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SELECT):GetFirst()
			Duel.MoveToField(csg,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
			e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
			csg:RegisterEffect(e1)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e2:SetType(EFFECT_TYPE_QUICK_O)
			e2:SetCode(EVENT_FREE_CHAIN)
			e2:SetRange(LOCATION_SZONE)
			e2:SetCountLimit(1)
			e2:SetCost(s.op1cst)
			e2:SetTarget(s.op1tg)
			e2:SetOperation(s.op1op)
			e2:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
			csg:RegisterEffect(e2)
		end
	end
end

function s.op1cst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) and 
	Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	Duel.DiscardDeck(tp,1,REASON_COST)
end

function s.op1tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.op1op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--effect 2
function s.cst2filter(c)
	return c:IsSetCard(0xf32) and c:IsType(TYPE_XYZ) and c:IsFacedown()
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and #g>0 end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONFIRM):GetFirst()
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleExtra(tp)
	e:SetLabel(sg:GetRank())
end

function s.tg2filter(c)
	return c:IsSetCard(0xf32) and c:HasLevel() and c:IsFaceup()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_MZONE,0,nil)
	local rk=e:GetLabel(e)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(rk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
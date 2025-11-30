--만화경의 시데르파그
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cst2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(s.tg3)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end

--effect 1
function s.tg1filter(c,e)
	return c:IsSpellTrap() and c:IsCanBeEffectTarget(e) and c:IsNegatable()
end

function s.tg1afilter(c)
	return c:IsSetCard(0xf33) and c:GetAttack()>=1000 and c:GetAttack()>c:GetBaseAttack() and c:IsFaceup()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and s.tg1filter(chkc,e) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,0,LOCATION_ONFIELD,nil,e)
	local ag=Duel.GetMatchingGroup(s.tg1afilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 and #ag>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_NEGATE)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,sg,1,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local ag=Duel.GetMatchingGroup(s.tg1afilter,tp,LOCATION_MZONE,0,nil)
	local tg=Duel.GetTargetCards(e):GetFirst()
	if #ag>0 then
		local asg=aux.SelectUnselectGroup(ag,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_FACEUP):GetFirst()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		asg:RegisterEffect(e1)
		if tg:IsNegatable() and tg then
			tg:NegateEffects(e:GetHandler(),nil,true)
		end
	end
end

--effect 2
function s.cst2filter(c)
	return c:IsSetCard(0xf33) and c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost()
end

function s.cst2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst2filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if chk==0 then return #g>1 end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.TRUE,1,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,124161293,0xf33,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,124161293,0xf33,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_EARTH) then return end
	local token=Duel.CreateToken(tp,124161293)
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end

--effect 3
function s.tg3(e,c)
	if not (c:IsType(TYPE_EQUIP) and c:IsType(TYPE_SPELL) and (c:IsFaceup() or c:GetEquipTarget())) then return false end
	local effs={c:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:GetCode()==EFFECT_UPDATE_ATTACK and eff:IsHasType(EFFECT_TYPE_EQUIP) then
			return true
		end
	end
	return false 
end
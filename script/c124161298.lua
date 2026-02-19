--검식검사 시데르파그
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():GetAttack()>e:GetHandler():GetBaseAttack() end)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.cst1filter(c)
	return c:IsSetCard(0xf33) and c:IsType(TYPE_SYNCHRO) and c:IsFacedown()
end

function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cst1filter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return #g>0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONFIRM)
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleExtra(tp)
end

function s.tg1filter(c,e,tp)
	if not (c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(e:GetHandler()) and c:CheckUniqueOnField(tp)) then return false end
	local effs={c:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:GetCode()==EFFECT_UPDATE_ATTACK and eff:IsHasType(EFFECT_TYPE_EQUIP) then
			return true
		end
	end
	return false 
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil,e,tp)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_DECK,0,nil,e,tp)
	if c:IsRelateToEffect(e) and c:IsFaceup() and #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_EQUIP):GetFirst()
		Duel.Equip(tp,sg,c)
	end
end

--effect 2
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetEquipCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,124161293,0xf33,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_EARTH) end
	local dt=(c:GetAttack()-c:GetBaseAttack())//500
	e:SetLabel(dt)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,124161293,0xf33,TYPES_TOKEN,0,0,1,RACE_FIEND,ATTRIBUTE_EARTH) then return end
	local token=Duel.CreateToken(tp,124161293)
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	local g=c:GetEquipGroup()
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		local dt=e:GetLabel()
		if dt>0 then
			local lv=Duel.AnnounceNumberRange(tp,0,dt)
			if lv>0 then
				Duel.BreakEffect()
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
				e1:SetCode(EFFECT_UPDATE_LEVEL)
				e1:SetValue(lv)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				token:RegisterEffect(e1)
			end
		end
	end
end
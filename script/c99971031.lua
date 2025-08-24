--[ Deadmoon ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=MakeEff(c,"FTo","H")
	e1:SetD(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	
	local e3=MakeEff(c,"Qo","M")
	e3:SetD(id,1)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCL(1)
	WriteEff(e3,3,"NTO")
	c:RegisterEffect(e3)
	
	local e4=MakeEff(c,"F","M")
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	e4:SetValue(s.aclimit)
	c:RegisterEffect(e4)
	
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return #eg==1 and eg:GetFirst():IsControler(1-tp)
end
function s.cost1f(c)
	return c:IsSetCard(0x9d71) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToGraveAsCost()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cost1f,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cost1f,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.op1f(c,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsSetCard(0x9d71) and c:CheckUniqueOnField(tp)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		local tg=Duel.GetMatchingGroup(s.op1f,tp,LOCATION_HAND,0,nil,tp)
		if #tg>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local eq=tg:Select(tp,1,1,nil):GetFirst()
			if Duel.Equip(tp,eq,c,true) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				e1:SetValue(function(e,c) return c==e:GetLabelObject() end)
				e1:SetLabelObject(c)
				eq:RegisterEffect(e1)
			end
		end
	end
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and re:GetActivateLocation()==LOCATION_MZONE
		and e:GetHandler():GetEquipCount()>0
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateEffect(ev) and c:IsRelateToEffect(e) and c:IsControler(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		local seq=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
		if seq then
			Duel.MoveSequence(c,math.log(seq,2))
		end
	end
end

function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	local g=e:GetHandler():GetColumnGroup()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsLocation(LOCATION_MZONE) and g:IsContains(rc)
end

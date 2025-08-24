--[ Deadmoon ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=MakeEff(c,"FTo","H")
	e1:SetD(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCL(1,id)
	e1:SetCost(Cost.SelfDiscard)
	WriteEff(e1,1,"NTO")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	
	local e3=MakeEff(c,"Qo","G")
	e3:SetCategory(CATEGORY_EQUIP+CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCL(1,{id,1})
	WriteEff(e3,3,"CTO")
	c:RegisterEffect(e3)
	
	local e4=MakeEff(c,"FC","S")
	e4:SetCode(EVENT_CHAIN_SOLVING)
	WriteEff(e4,4,"NO")
	c:RegisterEffect(e4)
	aux.DoubleSnareValidity(c,LOCATION_SZONE)
	
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return #eg==1 and eg:GetFirst():IsControler(1-tp)
end
function s.tar1f(c,e,tp)
	return c:IsCode(99971031) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())
		and Duel.IsExistingMatchingCard(s.tar1f,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tar1f),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.cost3f(c,tp,ft)
	return c:IsAbleToGraveAsCost() and c:IsOriginalType(TYPE_MONSTER) and (ft>0 or (c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5))
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,99971031),tp,LOCATION_MZONE,0,1,c)
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cost3f,tp,LOCATION_ONFIELD,0,1,nil,tp,ft) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cost3f,tp,LOCATION_ONFIELD,0,1,1,nil,tp,ft)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,99971031),tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_SZONE)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsCode,99971031),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not ec then return end
	Duel.HintSelection(ec,true)
	if Duel.Equip(tp,c,ec,true) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(function(e,c) return c==e:GetLabelObject() end)
		e1:SetLabelObject(ec)
		c:RegisterEffect(e1)
		if c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

function s.con4(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget() and rp==1-tp and re:IsTrapEffect() and Duel.IsChainDisablable(ev)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then
		Duel.Destroy(rc,REASON_EFFECT)
	end
end

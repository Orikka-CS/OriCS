--[ Blade Eater ]
local s,id=GetID()
function s.initial_effect(c)
	
	local e1=MakeEff(c,"I","M")
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)

	local e0=MakeEff(c,"I","HG")
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP+CATEGORY_DESTROY)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetCL(1,{id,1})
	WriteEff(e0,0,"TO")
	c:RegisterEffect(e0)
	
end

function s.tar0fil(c)
	return c:IsType(TYPE_EQUIP) and c:IsFaceup()
end
function s.tar0(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.tar0fil(chkc) end
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingTarget(s.tar0fil,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tar0fil,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.op0(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local eq=tc:GetEquipTarget()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if tc:CheckEquipTarget(c) then
			if Duel.Equip(tp,tc,c) and eq and eq:IsLocation(LOCATION_MZONE)
				and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Destroy(eq,REASON_EFFECT)
			end
		else
			if Duel.Destroy(tc,REASON_EFFECT)>0  and eq and eq:IsLocation(LOCATION_MZONE)
				and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Destroy(eq,REASON_EFFECT)
			end
		end
	end
end

function s.cfilter(c)
	return c:IsSetCard(0x5d70) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.eqfilter(c,tp)
	return c:IsSetCard(0x5d70) and c:CheckUniqueOnField(tp) and c:IsEquipSpell() and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then c=nil end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local stzone_check=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local sc=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,tp,stzone_check,c):GetFirst()
	if sc then
		Duel.Equip(tp,sc,c)
	end
end

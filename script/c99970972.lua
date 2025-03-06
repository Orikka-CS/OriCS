--[ ChaoticWing ]
local s,id=GetID()
function s.initial_effect(c)

	local e99=MakeEff(c,"F","MG")
	e99:SetCode(id)
	e99:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e99:SetTargetRange(1,0)
	c:RegisterEffect(e99)
	
	local e0=MakeEff(c,"FTo","G")
	e0:SetD(id,0)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_LEAVE_FIELD)
	e0:SetCL(1,{id,1})
	WriteEff(e0,0,"NTO")
	c:RegisterEffect(e0)

	local e1=MakeEff(c,"STo")
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCL(1,id)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	
end

s.listed_names={CARD_CYCLONE_GALAXY}

function s.con0fil(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT)
end
function s.con0(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsSpellEffect()
		and eg:IsExists(s.con0fil,1,nil)
end
function s.tar0(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
end
function s.op0(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		if Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

function s.tar1fil(c)
	return c:IsCode(CARD_CYCLONE_GALAXY) and c:IsSSetable() and (c:IsLocation(LSTN("DG")) or c:IsFaceup())
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar1fil,tp,LSTN("DGR"),0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tar1fil),tp,LSTN("DGR"),0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end

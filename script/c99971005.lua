--[ Taiyaki ]
local s,id=GetID()
function s.initial_effect(c)

	YuL.Activate(c)
	
	local e1=MakeEff(c,"I","F")
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCL(1)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"FTo","F")
	e2:SetD(id,0)
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_RECOVER)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHANGE_POS)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)

end

function s.tar1fil(c)
	return c:IsCode(99970999) and c:IsAbleToHand() and (c:IsLocation(LSTN("DG")) or c:IsFaceup())
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar1fil,tp,LSTN("DGR"),0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LSTN("DGR"))
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tar1fil),tp,LSTN("DGR"),0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.tar2fil(c,tp,g)
	return c:IsCode(99970999) and g:IsContains(c)
		and ((c:IsPosition(POS_FACEUP) and c:IsPreviousPosition(POS_FACEDOWN))
			or (c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsPreviousPosition(POS_FACEUP)))
end
function s.ovfil(c,sc,tp)
	return not c:IsCode(99970999) and c:IsSetCard(0x5d71) and c:IsM() and c:IsCanBeXyzMaterial(sc,tp,REASON_EFFECT)
end
function s.tar2fil2(c,e,tp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,nil,REASON_XYZ)
	return #pg<=0 and c:IsSetCard(0x5d71) and c:IsType(TYPE_XYZ)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.IsExistingMatchingCard(s.ovfil,tp,LOCATION_DECK,0,1,nil,c,tp)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.tar2fil,1,false,nil,nil,tp,eg)
		and Duel.IsExistingMatchingCard(s.tar2fil2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.tar2fil,1,1,false,nil,nil,tp,eg)
	Duel.Release(g,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.tar2fil2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	local og=Duel.GetMatchingGroup(s.ovfil,tp,LOCATION_DECK,0,nil,sc,tp)
	if #og>0 and Duel.SpecialSummonStep(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP) then
		sc:CompleteProcedure()
		if Duel.SpecialSummonComplete()==0 or #og<=0 then return end
		local sg=og:Select(tp,1,1,nil)
		Duel.Overlay(sc,sg)
		Duel.BreakEffect()
		Duel.Recover(tp,500,REASON_EFFECT)
	end
end

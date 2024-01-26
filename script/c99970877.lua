--[ Outer User ]
local s,id=GetID()
function s.initial_effect(c)

	RevLim(c)
	aux.AddXyzProcedureLevelFree(c,s.xfil1,s.xfil2,3,3)
	
	local e1=MakeEff(c,"STo")
	e1:SetD(id,0)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCL(1,YuL.S)
	WriteEff(e1,1,"NTO")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.con2)
	c:RegisterEffect(e2)
	
	local e3=MakeEff(c,"I","M")
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetCL(1,id)
	e3:SetCost(aux.dxmcostgen(3,3))
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
	
	local e4=MakeEff(c,"FTo","GR")
	e4:SetD(id,1)
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e4:SetCode(EVENT_CUSTOM+id)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCL(1,{id,1})
	WriteEff(e4,4,"TO")
	c:RegisterEffect(e4)

	if not s.global_check then
		s.global_check=true
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
		local ge2=MakeEff(c,"FC")
		ge2:SetCode(EVENT_CHAIN_ACTIVATING)
		ge2:SetOperation(s.gop2)
		Duel.RegisterEffect(ge2,0)
		local ge3=MakeEff(c,"FC")
		ge3:SetCode(EVENT_CHAIN_SOLVED)
		ge3:SetOperation(s.gop3)
		Duel.RegisterEffect(ge3,0)
	end

end

function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	local cc=Duel.GetCurrentChain()
	if cc>0 then
		local ce=Duel.GetChainInfo(cc,CHAININFO_TRIGGERING_EFFECT)
		if re==ce and re:IsActivated() then
			Duel.RegisterFlagEffect(0,id,RESET_CHAIN,0,0,cc)
		end
	end
end
function s.gop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.ResetFlagEffect(0,id)
end
function s.gop3(e,tp,eg,ep,ev,re,r,rp)
	local cc=Duel.GetCurrentChain()
	if Duel.GetFlagEffectLabel(0,id)~=cc and re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) then
		Duel.RaiseEvent(Group.CreateGroup(),EVENT_CUSTOM+id,re,r,rp,ep,ev)
	end
end

function s.xfil1(c,xyzc)
	return c:IsSetCard(0x9d6e) and c:IsLevelAbove(1)
end
function s.xfil2(g)
	return g:GetClassCount(Card.GetLevel)==g:GetCount()
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.tar1fil(c)
	return not c:IsType(TYPE_TOKEN) and c:IsAbleToChangeControler()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.tar1fil,tp,0,LOCATION_MZONE,1,c) end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	local tc=Duel.SelectMatchingCard(tp,s.tar1fil,tp,0,LOCATION_MZONE,1,1,c):GetFirst()
	if tc and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(c,tc,true)
	end
end


function s.tar3fil(c)
	return c:IsSetCard(0x9d6e) and c:IsAbleToGrave()
end
function s.op3fil(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and c:IsM() and c:IsLocation(LOCATION_GRAVE)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar3fil,tp,LOCATION_DECK,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tar3fil,tp,LOCATION_DECK,0,nil)
	if #g>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:Select(tp,2,2,nil)
		if Duel.SendtoGrave(sg,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then 
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local spg=sg:Filter(s.op3fil,nil,e,tp):Select(tp,1,1,nil)
			Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
		end
	end 
end

function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)
	local g=Duel.GetMatchingGroup(Card.IsMonster,1-tp,LOCATION_MZONE,0,nil)
	if #g>0 then
		local sg=g:Select(1-tp,1,1,nil)
		Duel.HintSelection(sg)
		if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_RULE,1-tp)>0
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsRelateToEffect(e)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			Duel.BreakEffect()
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

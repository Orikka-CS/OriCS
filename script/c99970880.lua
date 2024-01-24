--[ Outer User ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCL(1,id,YuL.O)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	
	local e4=MakeEff(c,"FTo","G")
	e4:SetD(id,1)
	e4:SetCode(EVENT_CUSTOM+id)
	e4:SetProperty(EFFECT_FLAG_DELAY)
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

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function s.cost1fil(c)
	return c:IsSetCard(0x9d6e) and c:IsM()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cost1fil,1,true,aux.ReleaseCheckTarget,nil,dg) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cost1fil,1,1,true,aux.ReleaseCheckTarget,nil,dg)
	Duel.Release(g,REASON_COST)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.op1fil(c,e,tp)
	return c:IsMonster() and (c:IsAbleToRemove() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.NegateActivation(ev) then return end
	if re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		if Duel.IsExistingMatchingCard(s.op1fil,tp,0,LOCATION_GRAVE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local tc=Duel.SelectMatchingCard(tp,s.op1fil,tp,0,LOCATION_GRAVE,1,1,nil):GetFirst()	
			if tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				and (not tc:IsAbleToRemove() or Duel.SelectYesNo(1-tp,aux.Stringid(id,2))) then
				Duel.SpecialSummon(tc,0,1-tp,tp,false,false,POS_FACEUP)
			else
				Duel.Remove(tc,POS_FACEDOWN,REASON_RULE,1-tp)
			end
		end
	end
end

function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3301)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECK)
		c:RegisterEffect(e1)
	end
end
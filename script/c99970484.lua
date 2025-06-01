--[ Insomnia ]
local s,id=GetID()
function s.initial_effect(c)
	
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,3,s.lcheck)
	
	local e1=MakeEff(c,"Qo","M")
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCL(2)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(s.chcon)
	e3:SetOperation(s.chop)
	c:RegisterEffect(e3)

	local e2=MakeEff(c,"FTo","G")
	e2:SetD(id,3)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_CHAIN_END)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCL(1,{id,1})
	e2:SetLabelObject(e3)
	WriteEff(e2,2,"NTO")
	c:RegisterEffect(e2)
	
end

function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0xe0a,lc,sumtype,tp) and c:IsRace(RACE_ZOMBIE,lc,sumtype,tp)
end
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(s.matfilter,1,nil,lc,sumtype,tp)
end

function s.cost1fil(c,g)
	return g:IsContains(c)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	local co=Duel.CheckReleaseGroupCost(tp,s.cost1fil,1,false,nil,nil,lg)
	if chk==0 then return co or not c:IsRace(RACE_SPELLCASTER) end
	if not co or (not c:IsRace(RACE_SPELLCASTER) and Duel.SelectYesNo(tp,aux.Stringid(99970478,2))) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_SPELLCASTER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	else
		local g=Duel.SelectReleaseGroupCost(tp,s.cost1fil,1,1,false,nil,nil,lg)
		Duel.Release(g,REASON_COST)
	end
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD|LOCATION_GRAVE) and chkc:IsAbleToRemove() and chkc:IsControler(1-tp) end
	if chk==0 then
		return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end

function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetCurrentChain()
	if ct>=3 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local res=e:GetLabelObject():GetLabel()
	e:GetLabelObject():SetLabel(0)
	return res==1
end
function s.op2fil(c)
	return c:IsSetCard(0xe0a) and c:IsSpellTrap() and c:IsSSetable()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_ZOMBIE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local g=Duel.GetMatchingGroup(s.op2fil,tp,LOCATION_DECK,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=g:Select(tp,1,1,nil)
			Duel.SSet(tp,sg)
		end
	end
end


--블록체인 인터커넥션 / Blockchain Interconnection
--Target contracts: ProjectIgnis proc_ritual.lua, utility.lua SelectUnselectGroup,
--official/c51124303.lua (simultaneous Ritual Summons; inspected 2026-09-22).
local s,id=GetID()
s.toss_coin=true
--Duel.LoadScript("blockchain.lua")
local B=Blockchain
function s.initial_effect(c)
	B.Init(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.rittg)
	e1:SetOperation(s.ritop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COIN+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.gycon)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
	s.ritual_matching_function=s.ritual_matching_function or {}
	s.ritual_matching_function[c]=function(tc) return tc:IsSetCard(B.SET) end
end
s.listed_series={0x6d72}
function s.ritfilter(c,e,tp)
	return c:IsSetCard(B.SET) and c:IsRitualMonster() and c:GetLevel()>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end

--A material contributes ONCE to the shared level total. Its alternative ritual
--levels must be legal for every monster in the simultaneous summon, so material
--selection never depends on which card Group:GetFirst happened to return.
function s.matlevel(c,rg)
	local values
	for rc in rg:Iter() do
		local v=c:GetRitualLevel(rc)
		local a,b=v&0xffff,v>>16
		if not values then
			values={}
			if a>0 then values[#values+1]=a end
			if b>0 and b~=a then values[#values+1]=b end
		else
			for i=#values,1,-1 do
				if values[i]~=a and values[i]~=b then table.remove(values,i) end
			end
		end
	end
	if not values or #values==0 then return 0 end
	return values[1]|((values[2] or 0)<<16)
end
function s.matfilter(c,rg,tp)
	if rg:IsContains(c) then return false end
	for rc in rg:Iter() do
		if not c:IsCanBeRitualMaterial(rc) or (rc.mat_filter and not rc.mat_filter(c,tp)) then
			return false
		end
	end
	return s.matlevel(c,rg)>0
end
function s.forcedmaterials(mg,tp)
	return mg:Filter(function(c)
		return c:IsControler(1-tp) and c:IsHasEffect(EFFECT_EXTRA_RELEASE)
	end,nil)
end
function s.materialcheck(rg,lv,required,extra)
	return function(mat,e,tp,mg,last)
		--Same redundant-tribute guard as Ritual.Check(RITPROC_GREATER).
		local minsum,minlast=0,0
		for mc in mat:Iter() do
			local v=s.matlevel(mc,rg)
			local a,b=v&0xffff,v>>16
			local n=b>0 and math.min(a,b) or a
			minsum=minsum+n
			if mc==last then minlast=n end
		end
		if last and minsum-minlast>lv then return false,true end
		if not mat:Includes(required) then return false end
		for rc in rg:Iter() do
			if rc.ritual_custom_check then
				local ok,stop=rc.ritual_custom_check(e,tp,mat,rc)
				if not ok or stop then return false,stop end
			end
			for _,f in ipairs(extra) do
				local ok,stop=f(e,tp,mat,rc)
				if not ok or stop then return false,stop end
			end
		end
		Duel.SetSelectedCard(mat)
		local ok=mat:CheckWithSumGreater(s.matlevel,lv,rg)
		return ok and Duel.GetMZoneCount(tp,mat,tp)>=#rg
	end
end
function s.materials(rg,e,tp,select)
	local lv=rg:GetSum(Card.GetLevel)
	if lv<=0 then return select and Group.CreateGroup() or false end
	local previous=Ritual.SummoningLevel
	Ritual.SummoningLevel=lv
	local raw=Duel.GetRitualMaterial(tp)
	local required=s.forcedmaterials(raw,tp)
	local mg=raw:Filter(s.matfilter,nil,rg,tp)
	local extra,seen={},{}
	for mc in mg:Iter() do
		for _,ef in ipairs({mc:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}) do
			local repl=ef:GetLabelObject()
			if repl and repl[1] and not seen[repl[1]] then
				extra[#extra+1]=repl[1]
				seen[repl[1]]=true
			end
		end
	end
	local result
	if mg:Includes(required) then
		local check=s.materialcheck(rg,lv,required,extra)
		result=aux.SelectUnselectGroup(mg,e,tp,1,math.min(#mg,lv),check,select and 1 or 0,
			tp,HINTMSG_RELEASE,check)
	else
		result=select and Group.CreateGroup() or false
	end
	Ritual.SummoningLevel=previous
	return result
end
function s.groupcheck(rg,e,tp)
	if #rg==0 or (#rg>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return false end
	return s.materials(rg,e,tp,false)
end
function s.singlepossible(c,e,tp)
	return s.groupcheck(Group.FromCards(c),e,tp)
end
function s.rittg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local rg=Duel.GetMatchingGroup(s.ritfilter,tp,LOCATION_DECK,0,nil,e,tp)
		return rg:IsExists(s.singlepossible,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.ritop(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetMatchingGroup(s.ritfilter,tp,LOCATION_DECK,0,nil,e,tp)
	local maximum=Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and 1 or 5
	local summoned=aux.SelectUnselectGroup(rg,e,tp,1,math.min(#rg,maximum),s.groupcheck,1,
		tp,HINTMSG_SPSUMMON,s.groupcheck)
	if #summoned==0 then return end
	local mat=s.materials(summoned,e,tp,true)
	if #mat==0 then return end
	for mc in mat:Iter() do
		for _,ef in ipairs({mc:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}) do
			local _,limit=ef:GetCountLimit()
			if limit>0 then
				ef:UseCountLimit(tp,1)
				Duel.RegisterFlagEffect(tp,ef:GetHandler():GetCode(),RESET_PHASE|PHASE_END,0,1)
			end
		end
	end
	for rc in summoned:Iter() do rc:SetMaterial(mat) end
	Duel.ReleaseRitualMaterial(mat)
	Duel.BreakEffect()
	for rc in summoned:Iter() do
		if Duel.SpecialSummonStep(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) then
			rc:CompleteProcedure()
		end
	end
	Duel.SpecialSummonComplete()
end
function s.blockmonster(c)
	return c:IsFaceup() and c:IsSetCard(B.SET) and c:IsMonster()
end
function s.gycon(e,tp)
	return Duel.IsExistingMatchingCard(s.blockmonster,tp,LOCATION_MZONE,0,1,nil)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() or c:IsAbleToRemove() end
	B.Track(e,tp)
end
function s.returnfilter(c)
	return c:IsFaceup() and c:IsSetCard(B.SET) and c:IsAbleToGrave()
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local result=B.Toss(e,tp)
	if not aux.NecroValleyFilter(aux.TRUE)(c) then return end
	if result==COIN_HEADS then
		if c:IsSSetable() then Duel.SSet(tp,c) end
	elseif c:IsAbleToRemove() and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.returnfilter,tp,LOCATION_REMOVED,0,0,2,nil)
		if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT|REASON_RETURN) end
	end
end

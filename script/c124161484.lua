--엔비램블 쥬노 오셀라이
local s,id=GetID()
function s.initial_effect(c)
	--link
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,99,s.linkfilter)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EFFECT_EXTRA_MATERIAL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(1,1)
	e0:SetOperation(s.extracon0)
	e0:SetValue(s.extraval0)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--count
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(s.cnt)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.curgroup=nil

--count
function s.cntfilter(c,tp)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE)
end

function s.cnt(e,c)
	local g=c:GetMaterial()
	local tp=c:GetControler()
	if c:IsType(TYPE_LINK) and g:IsExists(s.cntfilter,1,nil,tp) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
	end
end

--link
function s.linkfilter(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0xf3f,lc,sumtype,tp)
end

function s.closed_sky_filter(c)
	return not (c:HasFlagEffect(71818935) and #c:GetCardTarget()>0)
end

function s.extracon0(c,e,tp,sg,mg,lc,og,chk)
	if not s.curgroup then return true end
	local g=s.curgroup:Filter(s.closed_sky_filter,nil)
	local max_count=1
	local must_include=Group.CreateGroup()
	local effs={Duel.GetPlayerEffect(tp,EFFECT_EXTRA_MATERIAL)}
	for _,eff in ipairs(effs) do
		if not eff:GetOwner():IsCode(id) then
			if #(eff:GetValue()(0,SUMMON_TYPE_LINK,eff,tp,lc))>0 then
				local handler=eff:GetHandler()
				must_include:Merge(handler)
				if #(sg&must_include)>0 or lc==handler then
					max_count=max_count+1
				end
			end
		end
	end
	return #(sg&g)<=max_count
end

function s.extraval0(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or sc~=e:GetHandler() then
			return Group.CreateGroup()
		else
			s.curgroup=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
			s.curgroup:KeepAlive()
			return s.curgroup
		end
	elseif chk==2 then
		if s.curgroup then
			s.curgroup:DeleteGroup()
		end
		s.curgroup=nil
	end
end

--effect 1
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_MATERIAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(1,0)
		e1:SetOperation(s.extracon1)
		e1:SetValue(s.extraval1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local res=Duel.IsExistingMatchingCard(Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,1,nil)
		e1:Reset()
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=nil
	if c:IsRelateToEffect(e) then
		e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_MATERIAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(1,0)
		e1:SetOperation(s.extracon1)
		e1:SetValue(s.extraval1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,1,1,nil)
	local sc=sg:GetFirst()
	if sc then
		Duel.LinkSummon(tp,sc)
		if e1 then
			local eff_code=Duel.GetCurrentChain()==1 and EVENT_SPSUMMON or EVENT_SPSUMMON_SUCCESS
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(eff_code)
			e2:SetOperation(function(e) e1:Reset() e:Reset() end)
			Duel.RegisterEffect(e2,tp)
		end
	elseif e1 then
		e1:Reset()
	end
end

function s.extraval1filter(c)
	return c:IsFaceup() and c:IsMonster()
end

function s.extracon1filter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsSetCard(0xf3f) and c:IsMonster()
end

function s.extracon1(c,e,tp,sg,mg,lc,og,chk)
	local g=Duel.GetMatchingGroup(s.extraval1filter,tp,0,LOCATION_MZONE,nil)
	if #(sg&g)==0 then return true end
	return #(sg&g)<=1 and sg:IsExists(s.extracon1filter,1,nil,tp)
end

function s.extraval1(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK then
			return Group.CreateGroup()
		else
			return Duel.GetMatchingGroup(s.extraval1filter,tp,0,LOCATION_MZONE,nil)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK and #sg>0 then
			Duel.Hint(HINT_CARD,tp,id)
		end
	end
end

--effect 2
function s.con2filter(c,tp,mc)
	return c:IsControler(tp) and c~=mc and c:IsSummonType(SUMMON_TYPE_LINK) and c:GetFlagEffect(id)>0
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.con2filter,nil,tp,e:GetHandler())>0
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end
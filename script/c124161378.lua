--스큐드라스 부티크
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf38) end)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1a)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--effect 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end

--effect 1
function s.val1filter(c)
	return c:IsType(TYPE_XYZ) and c:IsSummonLocation(LOCATION_OVERLAY) and c:IsFaceup()
end

function s.val1(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.val1filter,tp,LOCATION_MZONE,0,nil)
	local x=0
	if #g==0 then return 0 end
	for tc in aux.Next(g) do
		x=x+tc:GetOverlayCount()
	end
	return x*300
end

--effect 2
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:GetHandler():IsType(TYPE_XYZ)
end

function s.tg2filter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
end

function s.op2gyfilter(c)
	return c:IsSetCard(0xf38) and not c:IsType(TYPE_FIELD)
end

function s.op2fieldfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #g>0 and Duel.GetLocationCountFromEx(tp) then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_SPSUMMON):GetFirst()
		if Duel.SpecialSummon(sg,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
			sg:CompleteProcedure()
			if Duel.SendtoGrave(sg,REASON_EFFECT)>0 and sg:IsLocation(LOCATION_GRAVE) then
				local gg=Duel.GetMatchingGroup(s.op2gyfilter,tp,LOCATION_GRAVE,0,nil)+sg
				local fg=Duel.GetMatchingGroup(s.op2fieldfilter,tp,LOCATION_MZONE,0,nil)
				if #gg>0 and #fg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
					Duel.BreakEffect()
					local gsg=aux.SelectUnselectGroup(gg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_XMATERIAL)
					local fsg=aux.SelectUnselectGroup(fg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_FACEUP):GetFirst()
					Duel.Overlay(fsg,gsg,true)
				end
			end
		end
	end
end

--effect 3
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) then
		local ex1,g1,gc1,dp1,loc1=Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
		local ex2,g2,gc2,dp2,loc2=Duel.GetPossibleOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
		local g=Group.CreateGroup()
		if g1 then g:Merge(g1) end
		if g2 then g:Merge(g2) end
		if (((loc1 or 0)|(loc2 or 0))&LOCATION_OVERLAY)>0 or (#g>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_OVERLAY)) then
			Duel.SetChainLimit(function(e,ep,tp) return ep==tp end)
		end
	end
end
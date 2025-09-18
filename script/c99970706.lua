--[ Nosferatu ]
local s,id=GetID()
function s.initial_effect(c)

	YuL.NosferatuDR(c,2000,3000)
	
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,3,3,s.lcheck)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_EXTRA_MATERIAL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e0:SetTargetRange(1,1)
	e0:SetOperation(s.op0)
	e0:SetValue(s.val0)
	c:RegisterEffect(e0)

	local e1=MakeEff(c,"S","M")
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.con1)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	
	local e2=MakeEff(c,"Qo","M")
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCost(Cost.SelfTribute)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)

	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		aux.AddValuesReset(function()
			s[0]=0
			s[1]=0
		end)
	end)
	
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if r&REASON_EFFECT~=0 or r&REASON_BATTLE~=0 then
		s[ep]=s[ep]+ev
	end
end

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,2,nil,0xe1e,lc,sumtype,tp)
end
function s.op0(c,e,tp,sg,mg,lc,og,chk)
	if not s.pg1 then
		return true
	end
	return #(sg&s.pg1)<=1
end
function s.val0f(c)
	return c:IsM() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function s.val0(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or sc~=c then
			return Group.CreateGroup()
		else
			s.pg1=Duel.GetMatchingGroup(s.val0f,tp,LOCATION_HAND,LOCATION_MZONE,nil)
			s.pg1:KeepAlive()
			return s.pg1
		end
	elseif chk==2 then
		if s.pg1 then
			s.pg1:DeleteGroup()
		end
		s.pg1=nil
	end
end

function s.con1(e)
	return s[e:GetHandlerPlayer()]>=3000
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end


function s.cost2f(c,g,e)
	return g:IsContains(c) or c==e:GetHandler()
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cost2f,1,false,nil,nil,lg,e) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cost2f,1,1,false,nil,nil,lg,e)
	Duel.Release(g,REASON_COST)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,math.floor(s[tp]/2000)+1,nil)
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
end

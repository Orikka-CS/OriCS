--¹«³à ¹ÌÄÚÅä
local s,id=GetID()
function s.initial_effect(c)
	--Inactivate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(s.discon)
	e1:SetCost(aux.SelfDiscardCost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		c99000133[0]=0
		c99000133[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(s.clearop)
		Duel.RegisterEffect(ge2,0)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsSummonType(SUMMON_TYPE_SPECIAL) then
			local p=tc:GetSummonPlayer()
			c99000133[p]=c99000133[p]+1
		end
		tc=eg:GetNext()
	end
end
function s.clearop(e,tp,eg,ep,ev,re,r,rp)
	c99000133[0]=0
	c99000133[1]=0
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	local loc2=re:GetHandler():GetLocation()
	if loc==0x108 then
		return loc~=loc2 and loc2~=0x8 and rp==1-tp and Duel.IsChainDisablable(ev)
	elseif loc==0x208 then
		return loc~=loc2 and loc2~=0x8 and rp==1-tp and Duel.IsChainDisablable(ev)
	else
		return loc~=loc2 and rp==1-tp and Duel.IsChainDisablable(ev)
	end
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	local ph=Duel.GetCurrentPhase()
	if tp==Duel.GetTurnPlayer() and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) then
		Duel.Damage(tp,c99000133[tp]*400,REASON_EFFECT)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetCondition(s.damcon)
		e1:SetOperation(s.damop)
		if ph==PHASE_MAIN1 then
			e1:SetReset(RESET_PHASE+PHASE_MAIN1)
		else
			e1:SetReset(RESET_PHASE+PHASE_MAIN2)
		end
		Duel.RegisterEffect(e1,tp)
	end
end
function s.cfilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Damage(tp,400,REASON_EFFECT)
end
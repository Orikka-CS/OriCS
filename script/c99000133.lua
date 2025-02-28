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
	if Duel.GetTurnPlayer()==1-tp then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetCondition(s.discon2)
		e1:SetOperation(s.disop2)
		if Duel.GetCurrentPhase()<=PHASE_STANDBY then
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		end
		Duel.RegisterEffect(e1,1-tp)
	end
end
function s.discon2(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	local loc2=re:GetHandler():GetLocation()
	if loc==0x108 then
		return loc~=loc2 and loc2~=0x8 and rp==1-tp and Duel.IsChainDisablable(ev) and e:GetHandler():GetFlagEffect(id)==0
	elseif loc==0x208 then
		return loc~=loc2 and loc2~=0x8 and rp==1-tp and Duel.IsChainDisablable(ev) and e:GetHandler():GetFlagEffect(id)==0
	else
		return loc~=loc2 and rp==1-tp and Duel.IsChainDisablable(ev) and e:GetHandler():GetFlagEffect(id)==0
	end
end
function s.disop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if Duel.GetFlagEffectLabel(tp,id)==cid or not Duel.SelectEffectYesNo(tp,c) then return end
	c:RegisterFlagEffect(id,0,0,1)
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1,cid)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateActivation(ev)
end
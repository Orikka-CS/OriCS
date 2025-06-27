--아크 노스탤지어
local m=99000218
local cm=_G["c"..m]
local s,id=GetID()
function cm.initial_effect(c)
	aux.AddCodeList(c,99000218)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,3,3,s.lcheck)
	--cannot link material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--inactivatable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_INACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(cm.effectfilter)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DISEFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(cm.effectfilter)
	c:RegisterEffect(e3)
	--effect gain
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(m,0))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(cm.discon2)
	e4:SetCost(cm.discost)
	e4:SetTarget(cm.distg2)
	e4:SetOperation(cm.disop2)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(cm.eftg)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
	--to hand
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(m,1))
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e6:SetCost(cm.cost)
	e6:SetTarget(cm.target)
	e6:SetOperation(cm.operation)
	c:RegisterEffect(e6)
	--to hand
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(m,2))
	e7:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e7:SetCondition(cm.con)
	e7:SetTarget(cm.target)
	e7:SetOperation(cm.operation)
	c:RegisterEffect(e7)
end
cm.card_code_list={99000218}
function s.lcheck(g,lc,sumtype,tp)
	return g:CheckDifferentPropertyBinary(Card.GetAttribute,lc,sumtype,tp)
end
function cm.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return p==tp and aux.IsCodeListed(te:GetHandler(),99000218) and bit.band(loc,LOCATION_ONFIELD)~=0
end
function cm.eftg(e,c)
	local lg=e:GetHandler():GetLinkedGroup()
	return c:IsType(TYPE_EFFECT) and aux.IsCodeListed(c,99000218) and lg:IsContains(c)
end
function cm.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function cm.discon2(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
function cm.distg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function cm.disop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(99000220)>0 and Duel.GetTurnPlayer()==tp
end
function cm.rfilter(c,att)
	return (not att or c:IsAttribute(att)) and c:IsType(TYPE_MONSTER) and c:IsCode(99000218) and c:IsAbleToRemoveAsCost()
end
cm.cost_table={ATTRIBUTE_EARTH,ATTRIBUTE_WATER,ATTRIBUTE_FIRE,ATTRIBUTE_WIND,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK}
function cm.rcostselector(c,g,sg,i)
	if not c:IsAttribute(cm.cost_table[i]) then return false end
	if i<6 then
		g:RemoveCard(c)
		sg:AddCard(c)
		local flag=g:IsExists(cm.rcostselector,1,nil,g,sg,i+1)
		g:AddCard(c)
		sg:RemoveCard(c)
		return flag
	else
		return true
	end
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(cm.rfilter,tp,LOCATION_GRAVE,0,nil)
	local sg=Group.CreateGroup()
	if chk==0 then return g:IsExists(cm.rcostselector,1,nil,g,sg,1) end
	for i=1,6 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g1=g:FilterSelect(tp,cm.rcostselector,1,1,nil,g,sg,i)
		g:Sub(g1)
		sg:Merge(g1)
	end
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
cm.AdditionalSetCardList={[0x6e]={47222536,85551711,23220863,71650854,48048590,51828629},
				[0x93]={99733359},
				[0x98]={21051146,31560081,40737112,41175645},
				[0x41]={55416843}}
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(99000218)==0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD)
	e:GetHandler():RegisterFlagEffect(99000218,RESET_PHASE+PHASE_END,0,1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(99000218)==0 then return end
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	e:GetHandler():SetHint(CHINT_CARD,ac)
	local chktoken=Duel.CreateToken(tp,ac)
	local ct=1
	while ct<=65535 do
		if (cm.AdditionalSetCardList[ct] and chktoken:IsCode(table.unpack(cm.AdditionalSetCardList[ct])))
			or chktoken:IsSetCard(ct) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_FORBIDDEN)
			e1:SetTargetRange(0x7f,0x7f)
			e1:SetTarget(cm.bantg)
			e1:SetLabel(ct)
			if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()<=PHASE_STANDBY then
				e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
			else
				e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			end
			Duel.RegisterEffect(e1,tp)
		end
		ct=ct+1
	end
end
function cm.bantg(e,c)
	local ct=e:GetLabel()
	return (cm.AdditionalSetCardList[ct] and c:IsCode(table.unpack(cm.AdditionalSetCardList[ct])))
		or c:IsSetCard(ct)
end
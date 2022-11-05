--영화원의 임볼크
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xfa1),1,1,aux.TRUE,1,99)
	c:EnableReviveLimit()
	--synchro level
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetOperation(s.synop)
	c:RegisterEffect(e1)
	--Return 1 opponent's card to Deck
	local e2=Effect.CreateEffect(c)
	--e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	--e2:SetCountLimit(1,id)
	--e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	local e4=e2:Clone()
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	c:RegisterEffect(e4)
	--Banish itself
	local e3=Effect.CreateEffect(c)
	--e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	--e3:SetCondition(function() return Duel.IsMainPhase() end)
	e3:SetCost(s.cost)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
	local cicbsm=Card.IsCanBeSynchroMaterial
	function Card.IsCanBeSynchroMaterial(mc,sc,...)
		if mc:GetLevel()==0 and sc==c then
			return true
		end
		if sc then
			return cicbsm(mc,sc,...)
		else
			return cicbsm(mc)
		end
	end
end
function s.synop(e,tg,ntg,sg,lv,sc,tp)
	local res=sg:CheckWithSumEqual(Card.GetSynchroLevel,lv,#sg,#sg,sc) 
		or sg:CheckWithSumEqual(function(c,s)
		if c:IsControler(1-tp) then
			return 7
		else
			return c:GetSynchroLevel(s)
		end
	end,lv,#sg,#sg,sc)
	return res,true
end
--destroy
function s.resfilter(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0xfa1)
end
function s.rescon(sg,e,tp,mg)
    return sg:IsExists(s.resfilter,1,nil,tp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,rg,2,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TODECK)
	if #g==2 then
		Duel.HintSelection(g,true)
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	if Duel.Remove(c,POS_FACEUP,REASON_COST+REASON_TEMPORARY)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetTurnCount()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(2000)
	e1:SetLabel(ct)
	e1:SetCondition(s.ocon31)
	e1:SetTarget(s.otar31)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(s.efilter)
	e3:SetReset(RESET_PHASE+PHASE_END,2)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetLabel(ct)
	e3:SetCondition(s.ocon31)
	e3:SetTarget(s.otar31)
	e3:SetOwnerPlayer(tp)
	Duel.RegisterEffect(e3,tp)
end
function s.ocon31(e)
	local ct=e:GetLabel()
	return Duel.GetTurnCount()~=ct and Duel.GetCurrentPhase()>PHASE_MAIN1 and Duel.GetCurrentPhase()<PHASE_MAIN2
end
function s.otar31(e,c)
	return c:IsSetCard(0xfa1)
end
function s.oval33(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
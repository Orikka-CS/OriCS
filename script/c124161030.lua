--Pyrthirio Phelegethon
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function() return Duel.GetCurrentPhase()==PHASE_END end)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.tg1g1filter(c,e)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(0xf21) and c:IsCanBeEffectTarget(e)
end

function s.tg1g2filter(c,e)
	return c:IsMonster() and c:IsCanBeEffectTarget(e)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.tg1g1filter,tp,LOCATION_MZONE,0,nil,e)
	local g2=Duel.GetMatchingGroup(s.tg1g2filter,tp,0,LOCATION_MZONE,nil,e)
	if chkc then return false end
	if chk==0 then return #g1>0 and #g2>0 end
	local sg1=aux.SelectUnselectGroup(g1,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DESTROY)
	local sg2=aux.SelectUnselectGroup(g2,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_DESTROY)
	sg1:Merge(sg2)
	Duel.SetTargetCard(sg1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg1,2,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetTargetCards(e)
	if #sg==2 and sg:FilterCount(Card.IsRelateToEffect,nil,e)==2 then
		if Duel.Destroy(sg,REASON_EFFECT)==0 then return end
		local dis=0
		local og=Duel.GetOperatedGroup()
		local target=og:GetFirst()
		for target in aux.Next(og) do
			dis=0
			dis=bit.replace(dis,0x1,target:GetPreviousSequence())
			if target:IsPreviousControler(1-tp) then  
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_DISABLE_FIELD)
				e1:SetLabel(dis*0x10000)
				e1:SetOperation(function(e) return e:GetLabel() end)
				e1:SetReset(RESET_PHASE+PHASE_END,2)
				Duel.RegisterEffect(e1,tp)
			else
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_DISABLE_FIELD)
				e1:SetLabel(dis*0x1)
				e1:SetOperation(function(e) return e:GetLabel() end)
				e1:SetReset(RESET_PHASE+PHASE_END,2)
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end

--effect 2
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_SZONE,PLAYER_NONE,0)>0 end
	local dis=Duel.SelectDisableField(tp,1,0,LOCATION_SZONE,0)
	Duel.Hint(HINT_ZONE,tp,dis)
	Duel.SetTargetParam(dis)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(function(e) return e:GetLabel() end)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetLabel(Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM))
	c:RegisterEffect(e1)
end
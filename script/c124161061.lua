--Unendal Recursion
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
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_DISABLE)
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
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--effect 1
function s.unendalf(c)
	return c:IsCode(124161058) and c:IsFaceup()
end


function s.tg1filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf23)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil)
	local eg=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,124161058)
	if chk==0 then return #mg>0 and ((#eg>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0) or Duel.IsExistingMatchingCard(s.unendalf,tp,LOCATION_SZONE,0,1,nil)) end
	local ch=Duel.GetCurrentChain()-1
	local trig_p,trig_e=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
	if ch>0 and trig_p==1-tp and trig_e:IsMonsterEffect() and Duel.IsChainDisablable(ch)
		then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_MZONE,0,nil)
	local eg=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,124161058)
	if #mg>0 and ((#eg>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0) or Duel.IsExistingMatchingCard(s.unendalf,tp,LOCATION_ONFIELD,0,1,nil)) then
		local seg=nil
		if Duel.IsExistingMatchingCard(s.unendalf,tp,LOCATION_ONFIELD,0,1,nil) then
			seg=Duel.GetMatchingGroup(s.unendalf,tp,LOCATION_ONFIELD,0,nil):GetFirst() 
		else
			seg=aux.SelectUnselectGroup(eg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_EQUIP):GetFirst()
		end
		local smg=aux.SelectUnselectGroup(mg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_EQUIP):GetFirst()
		Duel.Equip(tp,seg,smg)
	end
	local ch=Duel.GetCurrentChain()-1
	if e:GetLabel()==1 then
		Duel.NegateEffect(ch)
	end
end

--effect 2
function s.tg2filter(c,e,tp)
	return c:IsSetCard(0xf23) and c:IsFaceup() and c:IsCanBeEffectTarget(e) 
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_ONFIELD,0,e:GetHandler(),e,tp)
	local g2=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,0,LOCATION_SZONE,e:GetHandler(),e)
	if chkc then return false end
	if chk==0 then return #g1>0 and #g2>0 end
	local sg1=aux.SelectUnselectGroup(g1,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_RTOHAND)
	if #sg1==0 then return end
	local sg2=aux.SelectUnselectGroup(g2,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_RTOHAND)
	sg1:Merge(sg2)
	Duel.SetTargetCard(sg1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg1,2,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
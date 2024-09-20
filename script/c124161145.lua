--Xeridal, the Evil King of Liberation
local s,id=GetID()
function s.initial_effect(c)
	--synchro
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,s.tfilter,1,1,Synchro.NonTuner(Card.IsType,TYPE_SYNCHRO),1,99)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cst1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--synchro
s.material={124161138}
s.listed_names={124161138}
function s.tfilter(c,lc,stype,tp)
	return c:IsSummonCode(lc,stype,tp,124161138)
end
--effect 1
function s.cst1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(2)
	return true
end

function s.tg1filter(c)
	return c:IsSpellTrap() and c:IsSetCard(0xf29) and c:IsAbleToDeckAsCost() and c:CheckActivateEffect(false,true,true)~=nil and c:IsFaceup()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.tg1filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tg1filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end

--effect 2
function s.tg2filter(c)
	return c:IsSetCard(0xf29) and c:IsMonster() and not c:IsPublic()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>4 end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_HAND,0,nil)
	if g:GetClassCount(Card.GetCode)>4 then
		local sg=aux.SelectUnselectGroup(g,e,tp,5,5,aux.dncheck,1,tp,HINTMSG_CONFIRM)
		Duel.ConfirmCards(1-tp,sg)
		Duel.Win(tp,WIN_REASON_EXODIA)
	end  
end
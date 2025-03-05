--[ ChaoticWing ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	WriteEff(e1,1,"NCTO")
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
	
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local ch=ev-1
	if ch==0 or not (ep==1-tp and Duel.IsChainDisablable(ev)) or re:GetHandler():IsDisabled() then return false end
	local ch_eff=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT)
	return ch_eff:IsSpellEffect()
end
function s.cost1fil(c)
	return c:IsSetCard(0xcd70) and c:IsAbleToGraveAsCost()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cost1fil,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cost1fil,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev)~=0 then
		Duel.BreakEffect()
		local dg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		Duel.Destroy(dg,REASON_EFFECT)
	end
end

function s.hfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_CYCLONE,CARD_CYCLONE_GALAXY,CARD_CYCLONE_COSMIC,CARD_CYCLONE_DOUBLE,CARD_CYCLONE_DICE)
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.hfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
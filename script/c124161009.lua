--ElectroLightshape-Clair the Adamancy
local s,id=GetID()
function s.initial_effect(c)
	--synchro
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),1,1,Synchro.NonTuner(nil),1,99)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.tg2)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
end

--effect 1
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==tp and re:GetActivateLocation()==LOCATION_HAND 
end

function s.tg1filter(c)
	return c:IsPublic(e)
end

function s.tg1desfilter(c,e)
	return c:IsCanBeEffectTarget(e)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	local g=Duel.GetMatchingGroup(s.tg1filter,tp,LOCATION_HAND,0,nil)
	local dg=Duel.GetMatchingGroup(s.tg1desfilter,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return #g>0 and #dg>0 end
	local sg=aux.SelectUnselectGroup(dg,e,tp,1,#g,aux.TRUE,1,tp,HINTMSG_DESTROY)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end

function s.op1filter(c)
	return c:IsSetCard(0xf20) and not c:IsPublic() 
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
		local rg=Duel.GetMatchingGroup(s.op1filter,tp,LOCATION_HAND,0,nil)
		if #rg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local srg=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_CONFIRM)
			Duel.ConfirmCards(1-tp,srg)
			Duel.ShuffleHand(tp)
		end
	end
end

--effect 2
function s.tg2(e,c)
	return c:IsSetCard(0xf20)
end

--하얀 실: 초신성
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCondition(s.con2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.cost3)
	e3:SetTarget(s.tar3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetCountLimit(1,{id,1})
	e4:SetCost(s.cost3)
	e4:SetTarget(s.tar4)
	e4:SetOperation(s.op4)
	c:RegisterEffect(e4)
end
function s.con2(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,18454056),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.tfil3(c)
	return (c:IsCode(18454056) or c:IsCode(18454109)) and c:CheckActivateEffect(true,true,false)~=nil
		and c:IsAbleToGraveAsCost()
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()==0 then
			return false
		end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.tfil3,tp,LOCATION_ONFIELD,0,1,nil)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tfil3,tp,LOCATION_ONFIELD,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then
		tg(e,tp,ceg,cep,cev,cre,cr,crp,1)
	end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then
		return
	end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then
		op(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.cfil4(c,tp)
	return ((c:IsControler(tp) and c:IsSetCard(0xc01)) or c:IsHasEffect(18454353))
		and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_TRAP)
end
function s.tfil4(c)
	return c:IsSetCard(0xc01) and c:IsAbleToHand() and not c:IsType(TYPE_TRAP)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tfil4,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if chk==0 then
		if e:GetLabel()==0 then
			return false
		end
		e:SetLabel(0)
		return c:IsAbleToRemoveAsCost() and #g>0
	end
	local ct=g:GetClassCount(Card.GetCode)
	local sg=Group.FromCards(c)
	if ct>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=Duel.SelectMatchingCard(tp,s.cfil4,tp,LOCATION_GRAVE,LOCATION_GRAVE,0,1,c,tp)
		sg:Merge(rg)
	end
	e:SetLabel(#sg)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,#sg,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tfil4),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if #g<ct then
		return
	end
	local sg=aux.SelectUnselectGroup(g,e,tp,ct,ct,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	if sg then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND+LOCATION_ONFIELD,0,ct,ct,nil)
		Duel.HintSelection(dg)
		Duel.SendtoGrave(dg,REASON_EFFECT)
	end
end

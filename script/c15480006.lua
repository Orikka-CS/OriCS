--오성신 검법
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
end
s.listed_names={15480009}
function s.tfil11(c)
	return c:IsSetCard(0xffe) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.tfil12(c,tp)
	return c:IsCode(15480009) and c:IsFaceup() and c:IsControler(tp)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return e:GetLabel()==2 and chkc:IsOnField() and chkc~=c
	end
	local bc=Duel.GetBattleMonster(tp)
	local b3_event,_,event_p,event_v,event_reff=Duel.CheckEvent(EVENT_CHAINING,true)
	local tg=b3_event and Duel.GetChainInfo(event_v,CHAININFO_TARGET_CARDS) or nil
	local b1=Duel.IsExistingMatchingCard(s.tfil11,tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
	local b2=Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and bc and bc:IsCode(15480009) and bc:IsFaceup()
		and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
	local b3=b3_event and event_p==1-tp and event_reff:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and tg
		and tg:IsExists(s.tfil12,1,nil,tp) and Duel.IsChainDisablable(event_v)
	if chk==0 then
		return b1 or b2 or b3
	end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)},
		{b3,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(0)
		e:SetLabelObject(nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	elseif op==2 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetLabelObject(nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	elseif op==3 then
		e:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
		e:SetProperty(0)
		e:SetLabel(op,event_v)
		e:SetLabelObject(event_reff)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,event_reff:GetHandler(),1,tp,0)
		local rc=event_reff:GetHandler()
		if rc:IsRelateToEffect(event_reff) and rc:IsDestructable() then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,0,0)
		end
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local op,event_v=e:GetLabel()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tfil11),tp,LOCATION_DECK+LOCATION_GRAVE,
			LOCATION_GRAVE,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==2 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	elseif op==3 then
		local ere=e:GetLabelObject()
		local erc=ere:GetHandler()
		if Duel.NegateEffect(event_v) and erc:IsRelateToEffect(ere) then
			Duel.Destroy(erc,REASON_EFFECT)
		end
	end
end
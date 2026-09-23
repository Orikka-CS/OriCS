--블록체인 라일라
local s,id=GetID()
s.toss_coin=true
--Duel.LoadScript("blockchain.lua")
local B=Blockchain
s.listed_series={B.SET}
s.listed_names={B.INTERCONNECTION}
function s.initial_effect(c)
	c:EnableReviveLimit()
	B.Init(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	B.AddCoinQuick(c,id,s.coinop,CATEGORY_DESTROY|CATEGORY_TODECK|CATEGORY_TOHAND|CATEGORY_ATKCHANGE|CATEGORY_DEFCHANGE)
	B.AddReleasedRitual(c,id)
end
function s.thfilter(c)
	return c:IsSetCard(B.SET) and c:IsAbleToHand()
end
function s.coinop(e,tp)
	local ctx=B.Context(e)
	if B.Toss(e,tp)==COIN_HEADS then
		local bounce=ctx.previous_effect and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,3))
		Duel.Hint(HINT_SELECTMSG,tp,bounce and HINTMSG_TODECK or HINTMSG_DESTROY)
		local f=bounce and Card.IsAbleToDeck or aux.TRUE
		local g=Duel.SelectMatchingCard(tp,f,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			if bounce then Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			else Duel.Destroy(g,REASON_EFFECT) end
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then Duel.ConfirmCards(1-tp,g) end
		if ctx.responded then
			local mg=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsSetCard(B.SET) end,tp,LOCATION_MZONE,0,nil)
			for tc in aux.Next(mg) do
				local ae=Effect.CreateEffect(e:GetHandler())
				ae:SetType(EFFECT_TYPE_SINGLE)
				ae:SetCode(EFFECT_UPDATE_ATTACK)
				ae:SetValue(600)
				ae:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
				tc:RegisterEffect(ae)
				local de=ae:Clone()
				de:SetCode(EFFECT_UPDATE_DEFENSE)
				tc:RegisterEffect(de)
			end
		end
	end
end

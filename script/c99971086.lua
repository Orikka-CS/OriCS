--블록체인 크로마
--Blockchain Chroma
local s,id=GetID()
s.toss_coin=true
--Duel.LoadScript("blockchain.lua")
local B=Blockchain
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,7,2)
	B.Init(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.immune)
	c:RegisterEffect(e1)
	B.AddCoinQuick(c,id,s.coinop,CATEGORY_COIN|CATEGORY_RELEASE|CATEGORY_TODECK,1)
	B.AddReleasedRitual(c,id,2)
end
s.listed_series={0x6d72}
function s.immune(e,re)
	if not re:IsActivated() or re:GetHandlerPlayer()==e:GetHandlerPlayer() then return false end
	local index=B.EffectChainIndex(re)
	return index and index>0 and index%2==0
end
function s.deck_release(c,e,tp)
	return B.IsSetCard(c) and B.CanRelease(c,e,tp,REASON_EFFECT)
end
function s.coinop(e,tp)
	local ctx=B.Context(e)
	if B.Toss(e,tp)==COIN_HEADS then
		local g=Duel.GetMatchingGroup(s.deck_release,tp,LOCATION_DECK,0,nil,e,tp)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			B.Release(g:Select(tp,1,math.min(2,#g),nil),REASON_EFFECT,tp)
		end
		if ctx.previous_effect then
			local ne=Effect.CreateEffect(e:GetHandler())
			ne:SetType(EFFECT_TYPE_FIELD)
			ne:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			ne:SetCode(EFFECT_CANNOT_REMOVE)
			ne:SetTargetRange(0,1)
			ne:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(ne,tp)
		end
	else
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			Duel.SendtoDeck(g:Select(tp,1,math.min(3,#g),nil),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
		if ctx.responded then
			local ne=Effect.CreateEffect(e:GetHandler())
			ne:SetType(EFFECT_TYPE_FIELD)
			ne:SetCode(EFFECT_TO_GRAVE_REDIRECT)
			ne:SetProperty(EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_IGNORE_RANGE|EFFECT_FLAG_IGNORE_IMMUNE)
			ne:SetTargetRange(0,0xff)
			ne:SetTarget(function(e,c)
				return c:GetOwner()==1-e:GetOwnerPlayer() and Duel.IsPlayerCanRemove(e:GetOwnerPlayer(),c)
			end)
			ne:SetValue(LOCATION_REMOVED)
			ne:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(ne,tp)
		end
	end
end

--블록체인 신디아
--Blockchain Sindia
local s,id=GetID()
s.toss_coin=true
--Duel.LoadScript("blockchain.lua")
local B=Blockchain
function s.initial_effect(c)
	c:EnableReviveLimit()
	B.Init(c)
	--Custom wording: every new chain link, including Chain Link 1.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.banish_top)
	c:RegisterEffect(e1)
	B.AddCoinQuick(c,id,s.coinop,CATEGORY_COIN|CATEGORY_HANDES|CATEGORY_DRAW,1)
	B.AddReleasedRitual(c,id,2)
end
s.listed_series={0x6d72}
s.listed_names={99971089}
function s.banish_top(e,tp)
	local g=Duel.GetDecktopGroup(1-tp,1)
	if #g>0 then Duel.Remove(g,POS_FACEUP,REASON_EFFECT) end
end
function s.random_discard(tp)
	local g=Group.CreateGroup()
	for p=0,1 do
		local hg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
		if #hg>0 then g:Merge(hg:RandomSelect(p,1)) end
	end
	if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT|REASON_DISCARD) end
end
function s.summoned_by(c,p)
	return c:GetSummonPlayer()==p
end
function s.return_filter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsAbleToDeck()
end
function s.once_summon_return(e,tp,eg)
	--The first opponent summon consumes this delayed application, even if
	--none of that summon's monsters can still be returned at application.
	e:Reset()
	local g=eg:Filter(s.summoned_by,nil,1-tp):Filter(s.return_filter,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:Select(tp,1,1,nil)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function s.coinop(e,tp)
	local ctx=B.Context(e)
	if B.Toss(e,tp)==COIN_HEADS then
		s.random_discard(tp)
		if ctx.previous_effect then
			local de=Effect.CreateEffect(e:GetHandler())
			de:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			de:SetCode(EVENT_SPSUMMON_SUCCESS)
			de:SetCondition(function(e,tp,eg) return eg:IsExists(s.summoned_by,1,nil,1-tp) end)
			de:SetOperation(s.once_summon_return)
			de:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(de,tp)
		end
	else
		Duel.Draw(tp,1,REASON_EFFECT)
		Duel.Draw(1-tp,1,REASON_EFFECT)
		if ctx.responded then
			local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
			if #g>0 then Duel.ConfirmCards(tp,g) Duel.ShuffleHand(1-tp) end
		end
	end
end

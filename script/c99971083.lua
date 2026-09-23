--블록체인 올리브
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
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE|PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetOperation(s.endop)
	c:RegisterEffect(e1)
	B.AddCoinQuick(c,id,s.coinop,CATEGORY_RECOVER|CATEGORY_DAMAGE)
	B.AddReleasedRitual(c,id)
end
function s.endfilter(c,e,tp,handler)
	return (c==handler or not B.ActivatedInMzone(c)) and B.CanRelease(c,e,tp,REASON_EFFECT)
end
function s.endop(e,tp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.endfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp,c)
	if #g>0 then B.Release(g,REASON_EFFECT,tp) end
end
function s.coinop(e,tp)
	local ctx=B.Context(e)
	local heads=B.Toss(e,tp)==COIN_HEADS
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and B.CanRelease(c,e,tp,REASON_EFFECT) then B.Release(c,REASON_EFFECT,tp) end
	if heads and ctx.previous_effect then Duel.Recover(tp,2500,REASON_EFFECT)
	elseif not heads and ctx.responded then Duel.Damage(1-tp,2500,REASON_EFFECT) end
end

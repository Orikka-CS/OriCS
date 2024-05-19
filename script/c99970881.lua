--[ Colossus ]
local s,id=GetID()
function s.initial_effect(c)

	YuL.AddColossusSummonProcedure(c)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(4)
	c:RegisterEffect(e1)
	
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
	
	local e8=MakeEff(c,"STo")
	e8:SetCategory(CATEGORY_SEARCH_CARD+CATEGORY_SPECIAL_SUMMON)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCode(EVENT_RELEASE)
	WriteEff(e8,8,"NTO")
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EVENT_TO_GRAVE)
	e9:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetTurnPlayer()==tp and (r&REASON_ADJUST)~=0 end)
	c:RegisterEffect(e9)
	
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and e:GetHandler():IsRelateToBattle()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end

function s.con8(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_SUMMON)
end
function s.tar8fil(c,ft,e,tp)
	return c:IsSetCard(0x3d6f) and not c:IsCode(id) and c:IsM() and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tar8(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return Duel.IsExistingMatchingCard(s.tar8fil,tp,LOCATION_DECK,0,1,nil,ft,e,tp)
	end
end
function s.op8(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.tar8fil,tp,LOCATION_DECK,0,1,1,nil,ft,e,tp):GetFirst()
	if not sc then return end
	aux.ToHandOrElse(sc,tp,
		function(sc)
			return ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function(sc)
			return Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,0))
end

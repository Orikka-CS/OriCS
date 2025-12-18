--스노위퍼 아이반
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetValue(function() return 0,0x11 end)
	c:RegisterEffect(e1)
	--effect 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e2a=e2:Clone()
	e2a:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2a)
end

--effect 2
function s.tg2filter(c)
	return c:IsSetCard(0xf35) and c:IsSpell() and c:IsAbleToHand() 
end

function s.tg2dfilter(c,seq)
	local sq=c:GetSequence()
	return (sq==0 or sq==4) and seq~=4-sq
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 end
	local dg=Duel.GetMatchingGroupCount(s.tg2dfilter,tp,0,LOCATION_ONFIELD,nil,e:GetHandler():GetSequence())
	if dg>0 then e:SetLabel(1) else e:SetLabel(0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,LOCATION_DECK)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		local seq=math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0),2)
		Duel.MoveSequence(c,seq)
		local g=Duel.GetMatchingGroup(s.tg2filter,tp,LOCATION_DECK,0,nil)
		if #g>0 then
			local sg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_ATOHAND)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
			if e:GetLabel()==1 and Duel.IsPlayerCanDraw(tp,1) then
				Duel.BreakEffect()
				Duel.ShuffleDeck(tp)
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end
end
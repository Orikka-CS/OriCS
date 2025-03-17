--[ Taiyaki ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=MakeEff(c,"I","H")
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetCost(aux.SelfRevealCost)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"X","M")
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(function(e) return e:GetHandler():IsSetCard(0x5d71) end)
	e2:SetValue(function(e,c) return Duel.GetOverlayCount(0,1,1)*500 end)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	
end

function s.tar1fil(c,tp)
	return c:IsCode(99971005) and not c:IsForbidden() and c:CheckUniqueOnField(tp) and (c:IsLocation(LSTN("DG")) or c:IsFaceup())
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.tar1fil,tp,LSTN("DGR"),0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,2,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sc=Duel.SelectMatchingCard(tp,s.tar1fil,tp,LSTN("DGR"),0,1,1,nil,tp):GetFirst()
		if sc then
			local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
			if fc then
				Duel.SendtoGrave(fc,REASON_RULE)
				Duel.BreakEffect()
			end
			Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		end
	end
end

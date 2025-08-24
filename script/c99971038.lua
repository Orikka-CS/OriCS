--[ Deadmoon ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=MakeEff(c,"A")
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetCode(EVENT_FREE_CHAIN)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)

end

function s.cost1f(c,tp,ft)
	return c:IsAbleToGraveAsCost() and c:IsOriginalType(TYPE_MONSTER) and (ft>0 or (c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5))
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,99971031),tp,LOCATION_MZONE,0,1,c)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local check=Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(s.cost1f,tp,LOCATION_ONFIELD,0,1,nil,tp,ft)
	if chk==0 then return ft>0 or check end
	if check and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.cost1f,tp,LOCATION_ONFIELD,0,1,1,nil,tp,ft)
		Duel.SendtoGrave(g,REASON_COST)
		e:SetLabel(1)
		e:SetCategory(CATEGORY_EQUIP+CATEGORY_DRAW)
	else
		e:SetLabel(0)
	end
end
function s.tar1f1(c,tp)
	return Duel.IsExistingMatchingCard(s.tar1f11,tp,LOCATION_MZONE,0,1,nil,c)
end
function s.tar1f11(c,gc)
	return gc:GetColumnGroup():IsContains(c) and c:IsFaceup() and c:IsCode(99971031)
end
function s.tar1f2(c,tp)
	return c:IsSetCard(0x9d71) and c:IsRace(RACE_ZOMBIE) 
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,99971031),tp,LOCATION_MZONE,0,1,nil)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.IsExistingMatchingCard(s.tar1f1,tp,0,LOCATION_ONFIELD,1,nil,tp)
	local b=Duel.IsExistingMatchingCard(s.tar1f2,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp)
	if chk==0 then return a or b end
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
	local a=Duel.IsExistingMatchingCard(s.tar1f1,tp,0,LOCATION_ONFIELD,1,nil,tp)
	local b=Duel.IsExistingMatchingCard(s.tar1f2,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp)
	if not (a or b) then return end
	local op=nil
	if (a and b) then
		op=Duel.SelectEffect(tp,
			{a,aux.Stringid(id,0)},
			{b,aux.Stringid(id,1)})
	else
		op=(a and 1 or 2)
	end
	local eqtg=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsCode,99971031),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	local tc=nil
	if op==1 then
		tc=Duel.SelectMatchingCard(tp,s.tar1f1,tp,0,LOCATION_ONFIELD,1,1,nil,tp):GetFirst()
	else
		tc=Duel.SelectMatchingCard(tp,s.tar1f2,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	end
	if Duel.Equip(tp,tc,eqtg) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(function(e,c) return c==e:GetLabelObject() end)
		e1:SetLabelObject(eqtg)
		tc:RegisterEffect(e1)
	end
	if e:GetLabel()==1 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

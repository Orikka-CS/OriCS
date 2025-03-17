--[ Taiyaki ]
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCL(1,id)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"I","G")
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	
end
function s.ovfil(c)
	return c:IsCode(99971000,99971001)
end
function s.tar1fil(c,tp)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:IsSetCard(0x5d71)
		and Duel.IsExistingMatchingCard(s.ovfil,tp,LOCATION_DECK,0,1,nil)
end
function s.op1fil(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:IsSetCard(0x5d71)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.tar1fil,tp,LOCATION_MZONE,0,1,nil,tp) end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local res1=Duel.SelectCardsFromCodes(1-tp,1,1,false,false,{99971000,99971001})
	local res2=Duel.SelectCardsFromCodes(tp,1,1,false,false,{99971000,99971001})
	Duel.Hint(HINT_CARD,tp,res1)
	Duel.Hint(HINT_CARD,1-tp,res2)
	local tc=Duel.SelectMatchingCard(tp,s.op1fil,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	local g=nil
	local g2=nil
	if tc then
		if res1==res2 then
			g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK,0,1,1,nil,res1)
			if #g>0 then Duel.Overlay(tc,g) end
		else
			g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK,0,1,1,nil,res1)
			g2=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK,0,1,1,nil,res2)
			if #g>0 then Duel.Overlay(tc,g) end
			if #g2>0 then Duel.Overlay(tc,g2) end
		end
	end
end

function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res1=Duel.SelectCardsFromCodes(1-tp,1,1,false,false,{99971000,99971001})
	local res2=Duel.SelectCardsFromCodes(tp,1,1,false,false,{99971000,99971001})
	Duel.Hint(HINT_CARD,tp,res1)
	Duel.Hint(HINT_CARD,1-tp,res2)
	if res1~=res2 and c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end

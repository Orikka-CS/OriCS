--Tempetrix Absorption
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0xf24),nil,s.fextra,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	c:RegisterEffect(e1)
end

--effect 1
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end

function s.fextra(e,tp,mg,sumtype)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil),s.fcheck
end

function s.fcheck(tp,sg,fc,sumtype,tp)
	return true
end

function s.con1filter(c)
	return c:IsSetCard(0xf24) and c:IsFaceup()
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_MZONE,0,nil)
	return g>0
end

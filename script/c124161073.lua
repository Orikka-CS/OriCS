--사이클래시 트위스티리어
local s,id=GetID()
function s.initial_effect(c)
	--effect 1
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0xf24),extrafil=s.extrafil,extratg=s.extratg})
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	c:RegisterEffect(e1)
end

--effect 1
function s.fcheck(tp,sg,fc)
	return true
end

function s.extrafil(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil),s.fcheck
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end

function s.con1filter(c)
	return c:IsSetCard(0xf24) and c:IsFaceup()
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroupCount(s.con1filter,tp,LOCATION_MZONE,0,nil)
	return g>0
end

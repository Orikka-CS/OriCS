--이별 값이면 다홍 실
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsRace,FAIRY),Fusion.OnFieldMat,s.mg1,Fusion.BanishMaterial
		,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.tar1)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	c:RegisterEffect(e1)
end
function s.mg1(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_MZONE+LOCATION_GRAVE)
end
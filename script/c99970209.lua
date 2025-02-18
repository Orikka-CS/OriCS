--[ S¢Óigma ]
local s,id=GetID()
function s.initial_effect(c)

	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x6d70),1,3)

	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EFFECT_XYZ_LEVEL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(function(e,c) return c:IsRank(1) end)
	e0:SetValue(function(e,_,rc) return rc==e:GetHandler() and 1 or 0 end)
	c:RegisterEffect(e0)
	
	local e1=MakeEff(c,"Qo","M")
	e1:SetD(id,0)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCL(1,id)
	WriteEff(e1,1,"TO")
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) return c:IsSetCard(0x6d70) and c:IsAttribute(ATT_L) end)
	e2:SetValue(function(e,c) return e:GetHandler():GetOverlayCount()*700 end)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	
end

function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	local sg=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,#sg,0,0)
	if c:GetOverlayGroup():GetClassCount(Card.GetAttribute)==1 and c:GetOverlayGroup():IsExists(Card.IsAttribute,1,nil,ATT_L) then
		Duel.SetChainLimit(s.chlimit)
	end
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end

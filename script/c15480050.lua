--광성의 의식
local s,id=GetID()
function s.initial_effect(c)
	Ritual.AddProcGreater({handler=c,filter=s.tfil11,lv=Card.GetAttack,matfilter=s.tfil12,
		location=LOCATION_HAND|LOCATION_DECK,requirementfunc=Card.GetAttack,extrafil=s.tg1,extraop=s.op1})
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
s.listed_names={15480046}
function s.tfil11(c)
	return c:GetAttack()>0 and c:IsCode(15480046)
end
function s.tfil12(c)
	return c:IsRace(RACE_DRAGON) and c:GetAttack()>0
end
function s.tgfil1(c)
	return c:IsRace(RACE_DRAGON) and c:GetAttack()>0 and c:IsReleasableByEffect()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.tgfil1,tp,LOCATION_DECK,0,nil)
end
function s.op1(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
	mat:Sub(mat2)
	Duel.ReleaseRitualMaterial(mat)
	Duel.SendtoGrave(mat2,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL|REASON_RELEASE)
end
function s.tfil2(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil2,tp,LOCATION_EXTRA,0,2,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_EXTRA)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tfil2,tp,LOCATION_EXTRA,0,nil)
	if #g<2 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:Select(tp,2,2,nil)
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,sg)
end
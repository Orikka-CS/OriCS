--[ S¢Óigma ]
local s,id=GetID()
function s.initial_effect(c)

	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e6:SetCode(EFFECT_SPSUMMON_PROC)
	e6:SetRange(LOCATION_HAND)
	e6:SetCondition(s.con6)
	c:RegisterEffect(e6)
	
	local e1=MakeEff(c,"Qo","M")
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCL(1,id)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e2:SetCondition(function(e) return e:GetHandler():IsSetCard(0x6d70) and e:GetHandler():IsType(TYPE_XYZ) end)
	c:RegisterEffect(e2)
	
end

function s.con6(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x6d70),tp,LOCATION_MZONE,0,1,nil)
end

function s.tar1fil(c)
	return c:IsAbleToHand() and c:IsFaceup() and c:IsSetCard(0x6d70)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.tar1fil(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tar1fil,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.tar1fil,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	local dg=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,dg,1,tp,LOCATION_ONFIELD)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			g=g:Select(tp,1,1,nil)
			Duel.BreakEffect()
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end

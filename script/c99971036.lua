--[ Deadmoon ]
local s,id=GetID()
function s.initial_effect(c)

	YuL.Activate(c)

	local e3=Effect.CreateEffect(c)
	e3:SetD(id,0)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
	
	local e1=MakeEff(c,"FTf","F")
	e1:SetD(id,1)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	WriteEff(e1,1,"NTO")
	c:RegisterEffect(e1)
	local e4=e1:Clone()
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(function(e,c) return c:IsSetCard(0x9d71) and c:IsOriginalType(TYPE_MONSTER) end)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)

end

function s.tar3f(c)
	return c:IsSetCard(0x9d71) and c:IsAbleToHand()
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tar3f,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tar3f,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return #eg==1 and eg:GetFirst():IsControler(1-tp)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,eg,1,0,0)
end
function s.op1f(c,g)
	return c:IsFaceup() and c:IsCode(99971031) and g:IsContains(c)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetTargetCards(e):GetFirst()
	if not tc then return end
	local check=Duel.IsExistingMatchingCard(s.op1f,tp,LOCATION_MZONE,0,1,nil,tc:GetColumnGroup())
	if check and tc:IsControlerCanBeChanged() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.GetControl(tc,tp)
	end
end

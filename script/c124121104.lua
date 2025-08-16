--G.Rock 이볼브
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.con2)
	e3:SetTarget(s.tar2)
	e3:SetOperation(s.op2)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_XMATERIAL)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
end
function s.nfil1(c)
	return c:IsAbleToGraveAsCost() and c:IsType(TYPE_XYZ) and c:IsRank(9)
end
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.nfil1,tp,LOCATION_EXTRA,0,1,nil)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.nfil1,tp,LOCATION_EXTRA,0,0,1,nil)
	if #g>0 then
		e:SetLabelObject(g)
		g:KeepAlive()
		return true
	end
	return false
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then
		return
	end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c)
		return c:IsLocation(LOCATION_EXTRA) and
			not (c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_FIRE|ATTRIBUTE_EARTH|ATTRIBUTE_LIGHT))
	end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.addTempLizardCheck(c,tp,function(e,c)
		return not (c:IsOriginalType(TYPE_XYZ)
			and c:IsOriginalAttribute(ATTRIBUTE_FIRE|ATTRIBUTE_EARTH|ATTRIBUTE_LIGHT))
	end)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsType(TYPE_XYZ)
end
function s.tfil2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsOnField() and s.tfil2(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tfil2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.tfil2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
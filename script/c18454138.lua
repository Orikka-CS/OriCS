--¸£ºí¶û ¸®Á¶Æ®
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","F")
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTR(1,0)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"I","F")
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e3:SetCL(1,id)
	WriteEff(e3,3,"CTO")
	c:RegisterEffect(e3)
end
function s.val2(e,re,tp)
	local rc=re:GetHandler()
	return re:GetActivateLocation()&LOCATION_ONFIELD==0 and not rc:IsSetCard("¸£ºí¶û") and re:IsActiveType(TYPE_MONSTER)
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return true
	end
	Duel.MoveToField(c,tp,1-tp,LSTN("F"),POS_FACEUP,true)
end
function s.tfil3(c)
	return c:IsSetCard("¸£ºí¶û") and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.tfil3,tp,"D",0,1,nil)
	end
	Duel.SPOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
	Duel.SPOI(0,CATEGORY_TOGRAVE,nil,1,tp,"D")
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(tp,s.tfil3,tp,"D",0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then
		return
	end
	aux.ToHandOrElse(tc,tp)
end
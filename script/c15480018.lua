--드래곤세이버 라이트 슬래시
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
end
function s.nfil1(c)
	return c:IsFaceup() and c:IsSetCard(0xffe)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.nfil1,tp,LOCATION_MZONE,0,1,nil)
end
function s.tfil1(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsOnField() and chkc:IsControler(1-tp) and s.tfil1(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.tfil1,tp,0,LOCATION_ONFIELD,2,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.tfil1,tp,0,LOCATION_ONFIELD,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
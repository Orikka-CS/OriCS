--EE(이터널 엘릭서) 홀로그램
function c18454515.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,18454515+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(aux.RemainFieldCost)
	e1:SetTarget(c18454515.tar1)
	e1:SetOperation(c18454515.op1)
	c:RegisterEffect(e1)
end
function c18454515.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanSpecialSummonMonster(tp,18453234,0x2ea,0x4011,1000,1000,2,RACE_FAIRY,ATTRIBUTE_LIGHT)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function c18454515.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,18453234,0x2ea,0x4011,1000,1000,2,RACE_FAIRY,ATTRIBUTE_LIGHT)
		and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
		Duel.Exile(c,REASON_EFFECT+REASON_TEMPORARY)
		local token=Duel.CreateToken(tp,18453234)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetLabelObject(token)
		e1:SetOperation(c18454515.op11)
		Duel.RegisterEffect(e1,tp)
	end
end
function c18454515.op11(e,tp,eg,ep,ev,re,r,rp)
	local token=e:GetLabelObject()
	local c=e:GetHandler()
	if eg:IsContains(token) then
		Duel.SSet(tp,c)
		e:Reset()
	end
end
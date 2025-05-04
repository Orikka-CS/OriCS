--매크로 프시케
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","S")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCL(1)
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
end
s.listed_names={54493213}
function s.cfil2(c,tp)
	return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_TRAP) and (c:IsFaceup() or c:IsLoc("H"))
		and c:IsAbleToRemoveAsCost() and not c:IsCode(id)
		and (Duel.GetLocCount(tp,"S")>0 or (c:IsLoc("S") and c:GetSequence()<5))
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.cfil2,tp,"HO",0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SMCard(tp,s.cfil2,tp,"HO",0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc:IsLoc("H") then
		aux.RemoveUntil(tc,POS_FACEUP,REASON_COST,PHASE_END,id,e,tp,s.cop21)
	elseif tc:IsLoc("F") then
		aux.RemoveUntil(tc,POS_FACEUP,REASON_COST,PHASE_END,id,e,tp,s.cop22)
	else
		aux.RemoveUntil(tc,POS_FACEUP,REASON_COST,PHASE_END,id,e,tp,s.cop23)
	end
end
function s.cop21(rg,e,tp,eg,ep,ev,re,r,rp)
	local tc=rg:GetFirst()
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
function s.cop22(rg,e,tp,eg,ep,ev,re,r,rp)
	local fc=Duel.GetFieldCard(tp,LSTN("F"),0)
	if fc then
		Duel.SendtoGrave(fc,REASON_RULE)
		Duel.BreakEffect()
	end
	local tc=rg:GetFirst()
	Duel.MoveToField(tc,tp,tp,LSTN("F"),POS_FACEUP,true)
end
function s.cop23(rg,e,tp,eg,ep,ev,re,r,rp)
	local tc=rg:GetFirst()
	Duel.ReturnToField(tc)
end
function s.tfil2(c,bool)
	return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_TRAP) and not c:IsCode(id) and c:IsSSetable(bool)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil2,tp,"D",0,1,nil,true)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SMCard(tp,s.tfil2,tp,"D",0,1,1,nil,false)
	local tc=g:GetFirst()
	if tc and Duel.SSet(tp,g)>0 then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(s.ocon21)
		tc:RegisterEffect(e1)
	end
end
function s.onfil21(c)
	return c:IsCode(54493213) and c:IsFaceup()
end
function s.ocon21(e)
	local tp=e:GetOwnerPlayer()
	local c=e:GetHandler()
	return Duel.IEMCard(s.onfil21,tp,"O",0,1,nil) or c:ListsCode(54493213)
end
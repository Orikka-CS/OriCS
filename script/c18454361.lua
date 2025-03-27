--Ω ¿Ã»Ò «ÿ∏”ƒ´¿Ã≥™
local s,id=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,nil,3,3,s.pfil1,aux.Stringid(id,0),99,s.pop1)
	c:EnableReviveLimit()
	local e1=MakeEff(c,"S","M")
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"STo")
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"F","M")
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetTR("M","M")
	e4:SetCondition(s.con4)
	e4:SetTarget(s.tar4)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"F","M")
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetTR(0,"M")
	e5:SetValue(s.val5)
	c:RegisterEffect(e5)
	local e6=MakeEff(c,"FC","M")
	e6:SetCode(EVENT_CHAINING)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetOperation(aux.chainreg)
	c:RegisterEffect(e6)
	local e7=MakeEff(c,"FC","M")
	e7:SetCode(EVENT_CHAIN_SOLVED)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCondition(function(e) return e:GetHandler():HasFlagEffect(1) end)
	WriteEff(e7,7,"O")
	c:RegisterEffect(e7)
	local e8=MakeEff(c,"FTf","M")
	e8:SetCode(EVENT_PHASE+PHASE_END)
	e8:SetCL(1)
	WriteEff(e8,8,"TO")
	c:RegisterEffect(e8)
end
function s.pfil1(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard("Ω ¿Ã»Ò") and not c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,id)
end
function s.pop1(e,tp,chk)
	if chk==0 then
		return Duel.GetFlagEffect(tp,id)==0
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end
function s.vfil1(c)
	return c:IsSetCard("Ω ¿Ã»Ò") and c:GetAttack()>=0
end
function s.val1(e)
	local ec=e:GetHandler()
	local g=ec:GetOverlayGroup():Filter(s.vfil1,nil)
	return g:GetSum(Card.GetAttack)
end
function s.vfil2(c)
	return c:IsSetCard("Ω ¿Ã»Ò") and c:GetDefense()>=0
end
function s.val2(e)
	local ec=e:GetHandler()
	local g=ec:GetOverlayGroup():Filter(s.vfil2,nil)
	return g:GetSum(Card.GetDefense)
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("M") and chkc:IsControler(1-tp) and chkc:IsFaceup()
	end
	if chk==0 then
		return Duel.IEarget(Card.IsFaceup,tp,0,"M",1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.STarget(tp,Card.IsFaceup,tp,0,"M",1,1,nil)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local ct=Duel.IsTurnPlayer(tp) and 2 or 1
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetDescription(3206)
		e1:SetReset(RESETS_STANDARD_PHASE_END,ct)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetDescription(3302)
		tc:RegisterEffect(e2)
	end
end
function s.con4(e)
	local c=e:GetHandler()
	return c:GetOverlayCount()>0
end
function s.tar4(e,c)
	local ec=e:GetHandler()
	return c:IsSetCard("Ω ¿Ã»Ò") and c~=ec
end
function s.val5(e,c)
	local ec=e:GetHandler()
	return c:IsFaceup() and c:IsSetCaard("Ω ¿Ã»Ò") and c~=ec
end
function s.op7(e,tp,eg,ep,ev,re,r,rp)
	if re:IsSpellEffect() and rp==tp and re:GetHandler():IsSetCard("Ω ¿Ã»Ò") then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Recover(tp,100,REASON_EFFECT)
	end
end

function s.tar8(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.op8(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	end
end

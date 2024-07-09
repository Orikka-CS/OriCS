--¸£ºí¶û »çÀÏ·Î
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"F","H")
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTR(POS_FACEUP,1)
	e1:SetCondition(s.con1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","M")
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTR("M",0)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tar2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"FC","M")
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.op3)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"S","M")
	e4:SetCode(EFFECT_SET_CONTROL)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCondition(s.con4)
	e4:SetValue(s.val4)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"Qo","HM")
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetCategory(CATEGORY_ATKCHANGE)
	WriteEff(e5,5,"NCTO")
	c:RegisterEffect(e5)
end
function s.nfil1(c)
	return c:IsSetCard("¸£ºí¶û") and c:IsFaceup()
end
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.GetLocCount(1-tp,"M")>0 and Duel.IEMCard(s.nfil1,tp,"M",0,1,nil)
end
function s.con2(e)
	local c=e:GetHandler()
	return c:GetFlagEffect(id)~=0
end
function s.tar2(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(id)~=0 then
		return
	end
	local tc=eg:GetFirst()
	local fid=tc:GetFieldID()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end

function s.con4(e)
	return Duel.IsBattlePhase()
end
function s.val4(e,c)
	local handler=e:GetHandler()
	return handler:GetOwner()
end
function s.con5(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function s.cost5(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToHandAsCost() or c:IsLoc("H")
	end
	Duel.SendtoHand(c,1-tp,REASON_COST)
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsLoc("M") and chkc:IsControler(tp) and s.nfil1(chkc)
	end
	if chk==0 then
		return Duel.IETarget(s.nfil1,tp,"M",0,1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.STarget(tp,s.nfil1,tp,"M",0,1,1,nil)
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(2100)
		tc:RegisterEffect(e1)
	end
end
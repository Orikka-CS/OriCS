--영령의 방패
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"F","HG")
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCL(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"SC","M")
	e3:SetCode(EFFECT_SEND_REPLACE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetTarget(s.tar3)
	c:RegisterEffect(e3)
end
function s.nfil1(c,tp)
	return c:IsSetCard("방패") and c:IsFaceup() and c:IsAbleToHandAsCost() and Duel.GetMZoneCount(tp,c)>0
end
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.IEMCard(s.nfil1,tp,"O",0,1,nil,tp)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SMCard(tp,s.nfil1,tp,"O",0,0,1,nil,tp)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else
		return false
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then
		return
	end
	Duel.SendtoHand(g,nil,REASON_COST)
	g:DeleteGroup()
end
function s.cfil2(c)
	return c:IsSetCard("방패") and c:IsAbleToRemoveAsCost() and not c:IsCode(id)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.cfil2,tp,"G",0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SMCard(tp,s.cfil2,tp,"G",0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.tfil2(c)
	return c:IsSetCard("방패") and c:IsFaceup()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("R") and chkc:IsControler(tp) and s.tfil2(chkc)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil2,tp,"R",0,1,nil)
	end
	Duel.STarget(tp,s.tfil2,tp,"R",0,1,1,nil)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RULE)
	end
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:IsReason(REASON_REPLACE) and c:IsAbleToRemove() and c:GetFlagEffect(id-10000)==0
	end
	if Duel.GetFlagEffect(tp,FLAG_EFFECT_SHIELD)==0 then
		local e1=MakeEff(c,"FC")
		e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e1:SetOperation(s.top31)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,FLAG_EFFECT_SHIELD,0,0,0)
	end
	local fid=c:GetFieldID()
	Duel.Remove(c,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY+REASON_REPLACE)
	local e2=MakeEff(c,"FC")
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	if Duel.GetCurrentPhase()~=PHASE_DRAW then
		e2:SetLabel(Duel.GetTurnCount())
	else
		e2:SetLabel(0)
	end
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		e2:SetReset(RESET_PHASE+PHASE_STANDBY,2)
	else
		e2:SetReset(RESET_PHASE+PHASE_STANDBY)
	end
	e2:SetCL(1)
	e2:SetLabelObject({fid})
	e2:SetCondition(s.tcon32)
	e2:SetOperation(s.top32)
	Duel.RegisterEffect(e2,tp)
	local e3=MakeEff(c,"F")
	e3:SetCode(EFFECT_SHIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTR(1,0)
	e3:SetValue(2750)
	Duel.RegisterEffect(e3,tp)
	return true
end
function s.tcon32(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	return Duel.GetTurnCount()~=ct and c:GetFlagEffectLabel(id-10000)==fid
end
function s.top32(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.MoveToField(c,tp,tp,LSTN("M"),c:GetPreviousPosition(),true)
	c:RegisterFlagEffect(id-10000,RESET_EVENT+RESETS_STANDARD,0,0)
end
function s.top31(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then
		local amount=ev
		local eset={Duel.GetPlayerEffect(tp,EFFECT_SHIELD)}
		for _,te in ipairs(eset) do
			local loop=true
			local val=te:GetValue()
			if val>=amount then
				if val==amount then
					te:Reset()
				else
					te:SetValue(val-amount)
				end
				amount=0
				break
			else
				amount=amount-val
				te:Reset()
			end
		end
		if ev~=amount then
			Duel.ChangeBattleDamage(tp,amount)
		end
	end
end
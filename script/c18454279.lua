--월석의 방패
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"STo")
	e1:SetCode(id)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_CHANGE_POS)
	WriteEff(e2,2,"N")
	WriteEff(e2,1,"CTO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"SC","M")
	e3:SetCode(EFFECT_SEND_REPLACE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetTarget(s.tar3)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	if not s.global_check then	
		s.global_check=true
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_MSET)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		Duel.RaiseSingleEvent(tc,id,e,r,rp,ep,ev)
		tc=eg:GetNext()
	end
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return true
	end
	Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
end
function s.tfil1(c,tp)
	return c:IsSetCard("방패") and not c:IsCode(id)
		and ((Duel.GetFlagEffect(tp,id-10000)==0 and c:IsAbleToGrave())
			or (Duel.GetFlagEffect(tp,id-20000)==0 and c:IsAbleToRemove()))
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil,tp)
	end
	Duel.SPOI(0,CATEGORY_TOGRAVE,nil,1,tp,"D")
	Duel.SPOI(0,CATEGORY_REMOVE,nil,1,tp,"D")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		if (Duel.GetFlagEffect(tp,id-10000)==0 and tc:IsAbleToGrave())
			and (not (Duel.GetFlagEffect(tp,id-20000)==0 and tc:IsAbleToRemove())
				or not Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
			Duel.RegisterFlagEffect(tp,id-10000,RESET_PHASE+PHASE_END,0,1)
			Duel.SendtoGrave(tc,REASON_EFFECT)
		else
			Duel.RegisterFlagEffect(tp,id-20000,RESET_PHASE+PHASE_END,0,1)
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFacedown()
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:IsReason(REASON_REPLACE) and c:IsCanTurnSet() and c:GetFlagEffect(id-10000)==0
	end
	if Duel.GetFlagEffect(tp,FLAG_EFFECT_SHIELD)==0 then
		local e1=MakeEff(c,"FC")
		e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e1:SetOperation(s.top31)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,FLAG_EFFECT_SHIELD,0,0,0)
	end
	Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	c:RegisterFlagEffect(id-10000,RESET_EVENT+RESETS_STANDARD,0,0)
	local e2=MakeEff(c,"F")
	e2:SetCode(EFFECT_SHIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTR(1,0)
	e2:SetValue(1850)
	Duel.RegisterEffect(e2,tp)
	return true
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
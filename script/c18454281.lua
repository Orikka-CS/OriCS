--환희의 방패
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddDelightProcedure(c,s.pfil1,3,3)
	local e1=MakeEff(c,"I","M")
	WriteEff(e1,1,"CO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"SC","M")
	e2:SetCode(EFFECT_SEND_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetTarget(s.tar2)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		s[0]=0
		s[1]=0
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
	end
end
s.custom_type=CUSTOMTYPE_DELIGHT
function s.pfil1(c)
	return c:IsSetCard("방패")
end
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	s[0]=0
	s[1]=0
end
function s.cfil1(c,tp)
	return c:IsSetCard("방패") and c:IsFacedown() and c:IsType(TYPE_MONSTER) and c:GetAttribute()&s[tp]==0
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfil1,tp,LSTN("MR"),0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.cfil1,tp,LSTN("MR"),0,1,1,nil,tp)
	local tc=g:GetFirst()
	s[tp]=s[tp]|tc:GetAttribute()
	if tc:IsLoc("M") then
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	elseif tc:IsLoc("R") then
		Debug.ChangePositionEx(tc,POS_FACEUP)
		Debug.ChangePositionExMsg(tc)
		Duel.HintSelection(g)
		Duel.RaiseSingleEvent(tc,EVENT_FLIP,e,REASON_COST,tp,tp,0)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,FLAG_EFFECT_SHIELD)==0 then
		local e1=MakeEff(c,"FC")
		e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e1:SetOperation(s.oop11)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,FLAG_EFFECT_SHIELD,0,0,0)
	end
	local e2=MakeEff(c,"F")
	e2:SetCode(EFFECT_SHIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTR(1,0)
	e2:SetValue(4000)
	Duel.RegisterEffect(e2,tp)
	local sum=0
	local eset={Duel.GetPlayerEffect(tp,EFFECT_SHIELD)}
	for _,te in ipairs(eset) do
		local val=te:GetValue()
		sum=sum+val
	end
	Duel.Hint(HINT_NUMBER,tp,sum)
	Duel.Hint(HINT_NUMBER,1-tp,sum)
end
function s.oop11(e,tp,eg,ep,ev,re,r,rp)
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
			local sum=0
			local eset={Duel.GetPlayerEffect(tp,EFFECT_SHIELD)}
			for _,te in ipairs(eset) do
				local val=te:GetValue()
				sum=sum+val
			end
			Duel.Hint(HINT_NUMBER,tp,sum)
			Duel.Hint(HINT_NUMBER,1-tp,sum)
		end
	end
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:IsReason(REASON_REPLACE) and c:GetFlagEffect(id-10000)==0
	end
	if Duel.GetFlagEffect(tp,FLAG_EFFECT_SHIELD)==0 then
		local e1=MakeEff(c,"FC")
		e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e1:SetOperation(s.oop11)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,FLAG_EFFECT_SHIELD,0,0,0)
	end
	local ct=1
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		ct=2
	end
	aux.DelayTillPhase(c,tp,PHASE_STANDBY,ct)
	local ect=1
	if Duel.GetCurrentPhase()>=PHASE_STANDBY then
		ect=2
	end
	c:RegisterFlagEffect(id-10000,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,ect)
	local e2=MakeEff(c,"F")
	e2:SetCode(EFFECT_SHIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTR(1,0)
	e2:SetValue(4000)
	Duel.RegisterEffect(e2,tp)
	local sum=0
	local eset={Duel.GetPlayerEffect(tp,EFFECT_SHIELD)}
	for _,te in ipairs(eset) do
		local val=te:GetValue()
		sum=sum+val
	end
	Duel.Hint(HINT_NUMBER,tp,sum)
	Duel.Hint(HINT_NUMBER,1-tp,sum)
	return true
end
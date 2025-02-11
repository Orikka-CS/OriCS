--불사의 방패
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetCL(1,id,EFFECT_COUNT_CODE_OATH)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"Qo","G")
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"CTO")
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"SC","M")
	e3:SetCode(EFFECT_SEND_REPLACE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetTarget(s.tar3)
	c:RegisterEffect(e3)
end
function s.tfil1(c)
	return c:IsSetCard("방패") and c:IsAbleToGrave() and not c:IsCode(id)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil)
	end
	Duel.SOI(0,CATEGORY_TOGRAVE,nil,1,tp,"D")
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function s.cfil2(c)
	return c:IsSetCard("방패") and c:IsAbleToRemoveAsCost()
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IEMCard(s.cfil2,tp,"G",0,1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SMCard(tp,s.cfil2,tp,"G",0,1,1,c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocCount(tp,"M")>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,0x21,0,1800,3,RACE_ZOMBIE,ATTRIBUTE_DARK)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocCount(tp,"M")>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,0x21,0,1800,3,RACE_ZOMBIE,ATTRIBUTE_DARK) then
		c:AddMonsterAttribute(TYPE_EFFECT)
		Duel.SpecialSummon(c,1,tp,tp,true,false,POS_FACEUP_DEFENSE)
	end
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:IsReason(REASON_REPLACE) and c:IsCanTurnSet() and c:IsSummonType(SUMMON_TYPE_SPECIAL+1)
			and c:IsSSetable()
	end
	if Duel.GetFlagEffect(tp,FLAG_EFFECT_SHIELD)==0 then
		local e1=MakeEff(c,"FC")
		e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e1:SetOperation(s.top31)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,FLAG_EFFECT_SHIELD,0,0,0)
	end
	Duel.SSet(tp,c)
	local e2=MakeEff(c,"F")
	e2:SetCode(EFFECT_SHIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTR(1,0)
	e2:SetValue(1800)
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
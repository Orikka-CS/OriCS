--ÈæÃ¶ÀÇ ¹æÆÐ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,4,2)
	c:SetSPSummonOnce(id)
	local e1=MakeEff(c,"STo")
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"SC","M")
	e2:SetCode(EFFECT_SEND_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetTarget(s.tar2)
	c:RegisterEffect(e2)
end
function s.tfil1(c,e)
	return c:IsSetCard("¹æÆÐ") and not c:IsImmuneToEffect(e)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IEMCard(s.tfil1,tp,"D",0,1,nil,e)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SMCard(tp,s.tfil1,tp,"D",0,1,1,nil,e)
		if #g>0 then
			Duel.Overlay(c,g,true)
		end
	end
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:IsReason(REASON_REPLACE) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
	end
	if Duel.GetFlagEffect(tp,FLAG_EFFECT_SHIELD)==0 then
		local e1=MakeEff(c,"FC")
		e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e1:SetOperation(s.top21)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,FLAG_EFFECT_SHIELD,0,0,0)
	end
	c:RemoveOverlayCard(t,p1,1,REASON_EFFECT)
	local e2=MakeEff(c,"F")
	e2:SetCode(EFFECT_SHIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTR(1,0)
	e2:SetValue(2200)
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
function s.top21(e,tp,eg,ep,ev,re,r,rp)
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
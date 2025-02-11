--새천년 방패
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"F","H")
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCL(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"STo")
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCL(1,{id,1})
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"SC","M")
	e4:SetCode(EFFECT_SEND_REPLACE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetTarget(s.tar4)
	c:RegisterEffect(e4)
end
function s.nfil1(c)
	return c:IsSetCard("방패") and not c:IsCode(id) and (c:IsAbleToGraveAsCost() or c:IsAbleToRemoveAsCost())
end
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.GetLocCount(tp,"M")>0 and Duel.IEMCard(s.nfil1,tp,"D",0,1,nil)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SMCard(tp,s.nfil1,tp,"D",0,0,1,nil)
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
	local tc=g:GetFirst()
	if tc:IsAbleToGraveAsCost() and (not tc:IsAbleToRemoveAsCost() or not Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
		Duel.SendtoGrave(tc,REASON_COST)
	else
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
	end
	g:DeleteGroup()
end
function s.tfil2(c,e,tp)
	return (c:IsSSetable() or (Duel.GetLocCount(tp,"M")>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)))
		and c:IsFaceup() and c:IsSetCard("방패") and not c:IsCode(id)
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLoc("GR") and chkc:IsControler(tp) and s.tfil2(chkc,e,tp)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil2,tp,"GR",0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.STarget(tp,s.tfil2,tp,"GR",0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(0)
	end
	if tc:IsLoc("G") then
		Duel.SOI(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsSSetable() then
			Duel.SSet(tp,tc)
		else
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		end
	end
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not c:IsReason(REASON_REPLACE) and c:IsAbleToHand()
	end
	if Duel.GetFlagEffect(tp,FLAG_EFFECT_SHIELD)==0 then
		local e1=MakeEff(c,"FC")
		e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e1:SetOperation(s.top41)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,FLAG_EFFECT_SHIELD,0,0,0)
	end
	Duel.SendtoHand(c,nil,REASON_EFFECT+REASON_REPLACE)
	local e2=MakeEff(c,"F")
	e2:SetCode(EFFECT_SHIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTR(1,0)
	e2:SetValue(2000)
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
function s.top41(e,tp,eg,ep,ev,re,r,rp)
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
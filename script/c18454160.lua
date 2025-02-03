--크리보시아
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,1,2)
	local e1=MakeEff(c,"S","M")
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.val1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"F","M")
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTR("M",0)
	e2:SetTarget(s.tar2)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"Qo","M")
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetCL(1)
	WriteEff(e5,5,"CTO")
	c:RegisterEffect(e5)
	local e6=MakeEff(c,"F","G")
	e6:SetCode(EFFECT_EXTRA_MATERIAL)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTR(1,0)
	e6:SetValue(s.val6)
	e6:SetOperation(s.op6)
	c:RegisterEffect(e6)
	local e7=MakeEff(c,"SC")
	e7:SetCode(EVENT_BE_MATERIAL)
	e7:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	WriteEff(e7,7,"NO")
	c:RegisterEffect(e7)
end
function s.val1(e,te)
	if te:IsActiveType(TYPE_MONSTER) and te:IsActivated() then
		local rk=e:GetHandler():GetRank()
		local ec=te:GetOwner()
		if ec:IsType(TYPE_LINK) then
			return ec:GetLink()>rk
		elseif ec:IsType(TYPE_XYZ) then
			return ec:GetOriginalRank()>rk
		else
			return ec:GetOriginalLevel()>rk
		end
	else
		return false
	end
end
function s.tar2(e,c)
	return c:IsType(TYPE_LINK)
end
function s.cost5(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.cfil51(c,tp)
	return (c:IsCode(40640057) or c:IsCode(57116033)) and c:IsReleasable()
		and Duel.IEMCard(s.cfil52,tp,"D",0,1,nil,c:GetCode())
end
function s.cfil52(c,code)
	return c:ListsCode(code) and c:IsType(TYPE_QUICKPLAY)
		and c:CheckActivateEffect(false,true,true)~=nil
end
function s.tar5(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local og=c:GetOverlayGroup()
	if chk==0 then
		if e:GetLabel()==0 then
			return false
		end
		e:SetLabel(0)
		return #og>0 and Duel.IEMCard(s.cfil51,tp,"D",0,1,nil,tp)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local rg=og:Select(tp,1,1,nil)
	Duel.SendtoGrave(rg,REASON_COST+REASON_RELEASE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g1=Duel.SMCard(tp,s.cfil51,tp,"D",0,1,1,nil,tp)
	local rc=g1:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g2=Duel.SMCard(tp,s.cfil52,tp,"D",0,1,1,nil,rc:GetCode())
	local tc=g2:GetFirst()
	local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
	g1:Merge(g2)
	Duel.SendtoGrave(g1,REASON_COST+REASON_RELEASE)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then
		tg(e,tp,ceg,cep,cev,cre,cr,crp,1)
	end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then
		return
	end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then
		op(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.op6(c,e,tp,sg,mg,lc,og,chk)
	return true
end
function s.val6(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not c:IsAbleToRemove() then
			return Group.CreateGroup()
		else
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK then
		end
	elseif chk==2 then
	end
end
function s.con7(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
function s.op7(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=MakeEff(c,"S")
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetD(id,0)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	local e2=MakeEff(c,"S","M")
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetLabel(ep)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	e2:SetValue(s.oval72)
	rc:RegisterEffect(e2,true)
end
function s.oval72(e,re,rp)
	return rp==1-e:GetLabel()
end
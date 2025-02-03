--크리보사크
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunction(Card.IsLevel,1),2,2)
	local e1=MakeEff(c,"I","M")
	e1:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e1:SetD(id,1)
	e1:SetCL(1)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S","M")
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetCondition(s.con2)
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	local e4=MakeEff(c,"Qo","M")
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e4:SetD(id,2)
	e4:SetCL(1)
	WriteEff(e4,4,"NCTO")
	c:RegisterEffect(e4)
	local e5=MakeEff(c,"F","G")
	e5:SetCode(EFFECT_EXTRA_MATERIAL)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTR(1,0)
	e5:SetValue(s.val5)
	e5:SetOperation(s.op5)
	c:RegisterEffect(e5)
	local e6=MakeEff(c,"SC")
	e6:SetCode(EVENT_BE_MATERIAL)
	e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	WriteEff(e6,6,"NO")
	c:RegisterEffect(e6)
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=aux.GetMMZonesPointedTo(tp)
	local ct=Duel.GetLocCount(tp,"M",tp,LOCATION_REASON_TOFIELD,zone)
	if chk==0 then
		return ct>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_KURIBOH,0,TYPES_TOKEN,300,200,1,RACE_FIEND,ATTRIBUTE_DARK)
	end
	Duel.SOI(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,0)
	Duel.SOI(0,CATEGORY_TOKEN,nil,ct,tp,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=aux.GetMMZonesPointedTo(tp)
	local ct=Duel.GetLocCount(tp,"M",tp,LOCATION_REASON_TOFIELD,zone)
	if ct<=0 then
		return
	end
	for i=1,ct do
		local token=Duel.CreateToken(tp,TOKEN_KURIBOH)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP,zone)
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetDescription(3304)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()	
end
function s.nfil2(c)
	return c:IsFaceup() and c:IsLevel(1)
end
function s.con2(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IEMCard(s.nfil2,tp,"M",0,1,nil)
end
function s.con4(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function s.cfil4(c)
	return c:IsSetCard(0xa4)
end
function s.tfil4(c,e)
	return (not e or c:IsCanBeEffectTarget(e)) and (not c:IsCode(40640057) or c:IsNegatableMonster()
		or c:GetAttack()~=300 or (c:GetDefense()~=200 and c:IsDefenseAbove(0)))
end
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GMGroup(s.tfil4,tp,0,"M",nil,e)
	if chk==0 then
		return Duel.CheckReleaseGroupCost(tp,s.cfil4,1,false,aux.ReleaseCheckTarget,nil,dg)
	end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfil4,1,1,false,aux.ReleaseCheckTarget,nil,dg)
	Duel.Release(g,REASON_COST)
end
function s.tar4(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(1-tp) and chkc:IsLoc("M") and s.tfil4(chkc)
	end
	if chk==0 then
		return Duel.IETarget(s.tfil4,tp,0,"M",1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HITNMSG_FACEUP)
	local g=Duel.STarget(tp,s.tfil4,tp,0,"M",1,1,nil)
	Duel.SOI(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=MakeEff(c,"S")
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(40640057)
		tc:RegisterEffect(e1)
		local e2=MakeEff(c,"S")
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(300)
		tc:RegisterEffect(e2)
		local e3=MakeEff(c,"S")
		e3:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetValue(200)
		tc:RegisterEffect(e3)
		local e4=MakeEff(c,"S")
		e4:SetCode(EFFECT_DISABLE)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e4)
		local e5=MakeEff(c,"S")
		e5:SetCode(EFFECT_DISABLE_EFFECT)
		e5:SetValue(RESET_TURN_SET)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e5)
	end
end
function s.op5(c,e,tp,sg,mg,lc,og,chk)
	return true
end
function s.val5(chk,summon_type,e,...)
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
function s.con6(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
function s.op6(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=MakeEff(c,"S")
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetD(id,0)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	e2:SetValue(s.oval62)
	rc:RegisterEffect(e2,true)
end
function s.oval62(e,te)
	return te:IsActiveType(TYPE_SPELL)
end